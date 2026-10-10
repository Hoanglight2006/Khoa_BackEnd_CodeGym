# NHẬT KÝ TRA CỨU AI (AI PROMPT LOG)
**Dự án:** SmartFactory Real-time IoT Monitoring  
**Vai trò người dùng:** Database Optimization Expert  
**Vai trò AI:** Database Tuning Assistant  

---

### Prompt 1: Bản chất của Covering Index và tại sao nó giúp SELECT chạy siêu tốc?
* **Người dùng (Học viên):**
  > Giải thích cho tôi khái niệm "Covering Index" (Chỉ mục bao phủ) trong MySQL là gì? Tại sao nó giúp các câu lệnh SELECT đạt tốc độ tối đa mà không cần chạm vào ổ đĩa để đọc bảng chính?
* **Phản hồi từ AI:**
  * **Định nghĩa:** Covering Index là một chỉ mục (thường là Composite Index) chứa **toàn bộ** các cột dữ liệu được yêu cầu bởi câu truy vấn (bao gồm các cột trong `SELECT`, `WHERE`, `JOIN`, `ORDER BY`, `GROUP BY`).
  * **Cơ chế hoạt động:**
    1. Thông thường, một Secondary Index chỉ chứa các cột của index đó và con trỏ khóa chính (`Primary Key`). Khi bạn `SELECT` thêm các cột khác ngoài index, MySQL phải thực hiện bước phụ gọi là **Bookmark Lookup** (hoặc *Table Lookup*) để nhảy vào Clustered Index đọc toàn bộ dòng.
    2. Với Covering Index, mọi dữ liệu cần thiết đều nằm trọn vẹn trong các nút lá của cây B-Tree của Secondary Index. MySQL lấy dữ liệu ngay tại cây index và trả về cho client mà không phát sinh thêm bất kỳ thao tác I/O nào vào bảng chính.
  * Trong kết quả `EXPLAIN`, cột `Extra` sẽ hiển thị dòng chữ **`Using index`**.

---

### Prompt 2: Cách MySQL phân bổ dữ liệu trên Clustered Index và Secondary Index trong InnoDB
* **Người dùng (Học viên):**
  > Trong MySQL InnoDB, dữ liệu được phân bổ như thế nào giữa Clustered Index (Khóa chính) và Secondary Index (Chỉ mục phụ)? Tại sao mỗi phần tử của Secondary Index lại luôn đính kèm Primary Key?
* **Phản hồi từ AI:**
  1. **Clustered Index (Bảng dữ liệu vật lý):** 
     * InnoDB luôn lưu trữ bảng dưới dạng cây B+Tree theo Khóa chính (`PRIMARY KEY`). Các nút lá của cây này chứa toàn bộ các cột dữ liệu của từng dòng.
  2. **Secondary Index (Chỉ mục phụ):**
     * Là các cây B+Tree riêng biệt được tạo bổ sung. Các nút lá của Secondary Index **không chứa con trỏ địa chỉ bộ nhớ hay con trỏ ổ đĩa vật lý**, mà **luôn chứa giá trị của Primary Key** của dòng đó.
  3. **Hệ quả chi phí:**
     * Nếu Primary Key có kiểu dữ liệu lớn (ví dụ `BIGINT` = 8 bytes hoặc `UUID` = 36 bytes), thì **tất cả** các Secondary Index trên bảng đó đều tự động phình to thêm kích thước của Primary Key cho mỗi phần tử.

---

### Prompt 3: Tính toán chi tiết dung lượng Byte (Byte Calculation) cho từng cột trong MySQL
* **Người dùng (Học viên):**
  > Hãy giúp tôi tính toán kích thước tính theo Byte của từng trường trong bảng SensorLogs: `sensor_id INT`, `recorded_at DATETIME`, `temperature DECIMAL(5,2)`, `humidity DECIMAL(5,2)`, `status VARCHAR(20)`, và `log_id BIGINT`. Từ đó so sánh dung lượng 1 dòng của Fat Index so với Lean Index.
* **Phản hồi từ AI:**
  * **Bảng phân tích dung lượng:**
    * `sensor_id INT`: 4 bytes.
    * `recorded_at DATETIME`: 5 bytes (từ MySQL 5.6.4+).
    * `temperature DECIMAL(5,2)`: 3 bytes (5 chữ số với 2 số thập phân cần 3 bytes nhị phân).
    * `humidity DECIMAL(5,2)`: 3 bytes.
    * `status VARCHAR(20)`: 1 byte lưu độ dài + trung bình ~6 - 15 bytes văn bản (utf8mb4) $\approx$ 10 - 20 bytes.
    * `log_id BIGINT` (Primary Key đính kèm): 8 bytes.
  * **So sánh 1 mục Index (Index Entry Size):**
    * **Fat Index (`idx_fat_covering`):** $4 + 5 + 3 + 3 + 20 + 8 \approx \mathbf{43 - 50\text{ bytes}}$.
    * **Lean Index (`idx_lean_search`):** $4 + 5 + 8 = \mathbf{17\text{ bytes}}$.
  * **Kết luận:** Fat Index nặng gấp gần 3 lần Lean Index trên từng nút lá.

---

### Prompt 4: Cơ chế "Write Penalty" và hiện tượng nghẽn I/O trong hệ thống thời gian thực
* **Người dùng (Học viên):**
  > Giải thích tại sao trong hệ thống IoT nhận hàng chục nghìn lượt INSERT mỗi giây, việc kích thước Index quá lớn lại dẫn tới Data Loss (rớt dữ liệu) và chi phí ổ cứng AWS tăng phi mã?
* **Phản hồi từ AI:**
  * **InnoDB Page (16KB):** 
    * Một trang 16KB chỉ chứa được khoảng ~320 phần tử Fat Index so với gần ~950 phần tử Lean Index.
    * Tốc độ đầy trang diễn ra nhanh gấp 3 lần $\to$ Tần suất xảy ra **Page Split** tăng vọt.
  * **Nghẽn Write Pipeline & Data Loss:**
    * Page Split đòi hỏi khóa độc quyền (Exclusive Latch) trên cấu trúc B-Tree, buộc các luồng `INSERT` phía sau phải dừng chờ.
    * Khi hàng đợi kết nối của MySQL bị nghẽn (connection pool bão hòa), các tiến trình Data Pipeline của cảm biến IoT gặp lỗi connection timeout, dẫn tới rớt gói tin và mất dữ liệu.
  * **Hóa đơn AWS:**
    * Index phình to đẩy dung lượng `SensorLogs.ibd` lên hàng trăm Gigabyte, buộc phải nâng cấp dung lượng ổ cứng EBS SSD (gp3/io2) và tăng hạn mức IOPS tiêu thụ, khiến chi phí hóa đơn Cloud tăng gấp nhiều lần.
