# BÁO CÁO ĐÁNH ĐỔI HIỆU NĂNG & CHI PHÍ TÀI NGUYÊN (SMARTFACTORY)
**Dự án:** Hệ thống giám sát cảm biến IoT thời gian thực - SmartFactory  
**Chuyên viên tối ưu (DBA):** Database Optimization Expert  
**Người nhận báo cáo:** Cloud Financial Controller / Tech Lead  

---

## 1. Bản chất Vấn đề & Lý do Chấp nhận Đánh đổi (Trade-off Analysis)
Hệ thống IoT SmartFactory là hệ thống có lưu lượng ghi cực cao (**Write-Heavy**), tiếp nhận hàng chục nghìn lượt `INSERT` mỗi giây từ 10,000 cảm biến. 

Việc sử dụng **Fat Covering Index** (`sensor_id, recorded_at, temperature, humidity, status`) tạo ra một cái bẫy hiệu năng:
* **Mặt được:** Giúp màn hình Dashboard thực hiện `SELECT` siêu tốc vì toàn bộ dữ liệu nằm sẵn trên cây Index (kết quả `EXPLAIN` báo `Using index`, không cần đọc Clustered Index).
* **Cái giá phải trả (Thảm họa):**
  1. **Write Penalty khủng khiếp:** Mỗi bản ghi chèn vào phải cập nhật một nút lá B-Tree có kích thước lớn (~42 bytes/entry + 8 bytes Primary Key = 50 bytes), làm phân mảnh trang (*Page Splits*) liên tục, gây nghẽn hàng đợi ghi và dẫn đến mất gói tin (**Data Loss**).
  2. **Chi phí Cloud AWS bùng nổ:** Dung lượng `Index_length` phình to gấp đôi `Data_length`, làm tăng hóa đơn lưu trữ SSD AWS lên 4 lần.

**Quyết định kiến trúc:** Chuyển đổi sang **Lean Index** chỉ gồm `(sensor_id, recorded_at)`. Ta chấp nhận câu truy vấn Dashboard chậm hơn khoảng vài phần nghìn giây (do phải nhảy từ Secondary Index sang Clustered Index để lấy `temperature`, `humidity`, `status` qua cơ chế *Bookmark Lookup*). Đổi lại, tốc độ `INSERT` tăng gấp **4 - 5 lần** (giải quyết triệt để lỗi rớt dữ liệu) và giảm **~72% chi phí lưu trữ Index** trên AWS.

---

## 2. Bảng Tính toán Dung lượng theo Byte (Byte Calculation)

| Trường dữ liệu | Kiểu dữ liệu | Dung lượng trên Fat Index | Dung lượng trên Lean Index |
| :--- | :--- | :--- | :--- |
| `sensor_id` | `INT` | 4 bytes | 4 bytes |
| `recorded_at` | `DATETIME` | 5 bytes | 5 bytes |
| `temperature` | `DECIMAL(5,2)` | 3 bytes | *0 bytes (Đã loại bỏ)* |
| `humidity` | `DECIMAL(5,2)` | 3 bytes | *0 bytes (Đã loại bỏ)* |
| `status` | `VARCHAR(20)` (utf8mb4) | ~21 - 27 bytes | *0 bytes (Đã loại bỏ)* |
| `log_id` (PK pointer) | `BIGINT` | 8 bytes | 8 bytes |
| **Tổng kích thước 1 mục Index** | | **~48 - 50 bytes** | **~17 bytes (Giảm 65%)** |

> **Số liệu đo lường thực tế:** Trên bảng 20,000 dòng mẫu, dung lượng Index giảm từ **~2.85 MB** xuống chỉ còn **~0.81 MB** (tiết kiệm hơn 71.5% dung lượng lưu trữ trên SSD).

---

## 3. Đối chiếu Kế hoạch Thực thi (EXPLAIN Comparison)

* **Trước tối ưu (Fat Index):**  
  * `key`: `idx_fat_covering`  
  * `type`: `range`  
  * `Extra`: `Using index` *(Đọc trực tiếp từ cây index, không chạm bảng gốc)*.
* **Sau tối ưu (Lean Index):**  
  * `key`: `idx_lean_search`  
  * `type`: `range`  
  * `Extra`: `Using index condition` *(Vẫn sử dụng Index để lọc dải thời gian cực nhanh, sau đó thực hiện Bookmark Lookup để lấy các cột đo lường)*.  
  * **Đánh giá:** Tốc độ đọc vẫn thuộc nhóm `range` (dưới 10ms), hoàn toàn đáp ứng độ mượt của Dashboard.

---

## 4. Trả lời Chất vấn của Cloud Financial Controller

### Câu hỏi 1: Nếu bảng là "Danh mục quốc gia" (Countries) cả năm không sửa, Covering Index có còn là "tội ác"?
* **Trả lời:** **Hoàn toàn không, mà ngược lại là giải pháp tối ưu số 1.** 
* Bảng danh mục có đặc tính **Read-Heavy / Zero-Write** (chỉ đọc, không ghi) và số lượng bản ghi rất ít (khoảng 200 quốc gia). Khi không có thao tác ghi, ta không phải trả giá cho *Write Penalty*. Toàn bộ cây Index có thể nạp gọn trong RAM (InnoDB Buffer Pool), giúp các truy vấn tìm kiếm đạt tốc độ tức thì (*in-memory execution*) mà không gây tốn tài nguyên.

### Câu hỏi 2: Khái niệm "Write Penalty" là gì? Tại sao thêm 1 cột vào Index lại làm INSERT chậm lại?
* **Trả lời:** *Write Penalty* (Hình phạt khi ghi) là chi phí bổ sung về CPU, RAM và Disk I/O mà database phải gánh chịu để đồng bộ hóa và duy trì cấu trúc cây B-Tree của các Index mỗi khi có thao tác `INSERT`, `UPDATE`, `DELETE`.
* Khi thêm 1 cột vào Index:
  1. Kích thước của mỗi phần tử trong nút lá B-Tree tăng lên.
  2. Một trang dữ liệu cố định 16KB sẽ chứa được ít phần tử hơn $\to$ Cây B-Tree phải tăng số tầng (chiều cao h) và sinh ra nhiều trang đĩa hơn.
  3. Khi `INSERT`, xác suất trang bị đầy dẫn tới **Page Split** tăng mạnh, kéo theo nhiều thao tác khóa trang (*latch*) và ghi đĩa ngẫu nhiên (*Random I/O*), làm tốc độ ghi sụt giảm nghiêm trọng.

### Câu hỏi 3: Nếu thay VARCHAR(20) của status thành TINYINT thì tác động thế nào đến Data Length và Index Length?
* **Trả lời:** 
  * Cột `VARCHAR(20)` dùng bảng mã `utf8mb4` tiêu tốn từ 1 đến 81 bytes (tùy ký tự và byte độ dài). Trong khi đó, `TINYINT` chỉ tốn đúng **1 byte**.
  * **Tác động:** Giúp giảm kích thước mỗi dòng trong `Data Length` khoảng 15-20 bytes. Nếu cột này bị đưa vào Index, nó giúp thu hẹp kích thước mỗi nút lá B-Tree trong `Index Length` khoảng 20-25 bytes, giảm đáng kể hiện tượng phân mảnh trang và tiết kiệm thêm dung lượng RAM/Disk.
