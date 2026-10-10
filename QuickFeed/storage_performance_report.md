# BÁO CÁO PHÂN TÍCH TÀI NGUYÊN VÀ HIỆU NĂNG HỆ THỐNG QUICKFEED
**Dự án:** QuickFeed Platform  
**Người thực hiện:** Database Administrator (DBA)  
**Người nhận báo cáo:** Tech Lead  

---

## 1. Tóm tắt Đánh đổi Hiệu năng: Đọc (Read) vs Ghi (Write) Trade-off
Index trong MySQL hoạt động theo cấu trúc cây cân bằng (B-Tree). Mặc dù Index giúp tăng tốc các truy vấn đọc (`SELECT`), nó áp đặt một chi phí khổng lồ lên thao tác ghi (`INSERT`, `UPDATE`, `DELETE`). 

Cụ thể, khi một bài viết mới được đăng (`INSERT`):
* Không chỉ thêm 1 dòng vào bảng dữ liệu chính (Clustered Index).
* MySQL còn phải đồng thời cập nhật và cân bằng lại **toàn bộ 5 cây B-Tree phụ (Secondary Indexes)**.
* Mỗi cây B-Tree phải thực hiện tìm nút lá tương ứng, phân chia trang đĩa (*Page Split*) nếu trang đầy, và ghi I/O ngẫu nhiên xuống ổ đĩa. Do đó, 1 thao tác ghi bị nhân lên thành 6 thao tác ghi vật lý, dẫn đến nghẽn hàng đợi I/O và người dùng gặp lỗi **Timeout (5-10s)** khi đăng bài.

---

## 2. Ma trận Quyết định (Decision Matrix) & Độ phân biệt (Cardinality)

| Tên Index | Cột áp dụng | Cardinality | Đánh giá & Quyết định | Lý do kỹ thuật |
| :--- | :--- | :--- | :--- | :--- |
| `PRIMARY` | `post_id` | Rất cao (Unique) | **GIỮ** | Clustered Index mặc định của InnoDB. |
| `idx_user_id` | `user_id` | Cao | **GIỮ** | Cần thiết để load trang cá nhân của từng user (`WHERE user_id = ?`). |
| `idx_created_at` | `created_at` | Rất cao | **GIỮ** | Cần thiết để tải bảng tin mới nhất (`ORDER BY created_at DESC`). |
| `idx_content` | `content(255)` | Trung bình | **XÓA (DROP)** | Chiếm dung lượng quá lớn trên bộ đệm InnoDB Buffer Pool. Tìm kiếm bài viết cần dùng **FULLTEXT Index**, không dùng B-Tree prefix. |
| `idx_post_type` | `post_type` | Cực thấp (3 giá trị) | **XÓA (DROP)** | Độ chọn lọc quá thấp (`'TEXT'`, `'IMAGE'`, `'VIDEO'`). |
| `idx_is_visible` | `is_visible` | Cực thấp (2 giá trị) | **XÓA (DROP)** | Chỉ có 0 và 1 (hơn 95% là 1). MySQL Query Optimizer sẽ bỏ qua Index này và dùng Full Table Scan vì chi phí duyệt index + lookup đắt hơn đọc tuần tự. |

---

## 3. Bảng Số liệu Đo lường Dung lượng (Storage Metrics)

Truy vấn đối chiếu từ `information_schema.TABLES` trên tập dữ liệu mô phỏng 10,000 bản ghi:

| Trạng thái | Data Length | Index Length | Tỉ lệ Index / Data | Tổng dung lượng |
| :--- | :--- | :--- | :--- | :--- |
| **Trước tối ưu (5 Indexes)** | ~1.52 MB | ~2.98 MB | **~196%** (Index lớn gấp đôi Data) | ~4.50 MB |
| **Sau tối ưu (2 Indexes)** | ~1.52 MB | ~0.64 MB | **~42%** (Giảm ~78% dung lượng Index) | ~2.16 MB |

> **Kết luận vận hành:** Cắt bỏ 3 Index vô dụng đã giúp giải phóng gần **78% dung lượng đĩa của cây Index**, đồng thời giảm **60% chi phí cập nhật B-Tree** cho mỗi lần người dùng bấm nút "Đăng status".

---

## 4. Trả lời Câu hỏi Vấn đáp (Tech Lead Q&A)

### Câu hỏi 1: Điều gì xảy ra ở tầng vật lý (ổ cứng) khi INSERT vào bảng có 5 Index? Tại sao người dùng bị Timeout?
* **Trả lời:** Khi thực hiện `INSERT`, MySQL ghi dữ liệu vào Clustered Index (Primary Key), sau đó phải cập nhật tiếp 5 cây B-Tree phụ. 
* Do các giá trị của 5 index không liên tục, MySQL phải thực hiện **Random I/O** để tìm đúng khối dữ liệu (*Data Page*) của từng cây trên đĩa. Nếu một Page bị đầy, hệ thống phải thực hiện **Page Split** (cấp phát trang mới, chia đôi dữ liệu, cập nhật con trỏ cây B-Tree).
* Nhiều người cùng đăng bài tạo ra hiện tượng nghẽn I/O (Disk I/O Bottleneck), các transaction phải xếp hàng chờ khóa (*latch contention*), dẫn tới ứng dụng chạm ngưỡng Timeout (5-10 giây).

### Câu hỏi 2: Cardinality là gì? Tại sao cột Giới tính hoặc Trạng thái lại tồi tệ nhất khi tạo Index B-Tree?
* **Trả lời:** Cardinality là số lượng giá trị phân biệt (unique values) trong một cột dữ liệu.
* Với cột Giới tính (Nam/Nữ) hoặc Trạng thái (0/1), Cardinality chỉ bằng 2. Khi đó, một giá trị chiếm tới 50% hoặc 90% toàn bộ bảng.
* Nếu dùng B-Tree Index, MySQL phải dò trong cây Index trước, rồi thực hiện phép tra cứu ngược lại bảng chính (*Bookmark Lookup / Secondary Key to Primary Key lookup*) cho hàng triệu dòng. Quá trình này tạo ra hàng triệu thao tác Random I/O, chậm hơn rất nhiều so với việc đọc tuần tự (*Sequential Read*) toàn bộ bảng (**Full Table Scan**). Do đó, Query Optimizer sẽ bỏ qua Index này, biến nó thành "rác" chỉ tốn dung lượng lưu trữ và chi phí bảo trì ghi.

### Câu hỏi 3: Nếu bảng Posts là bảng lịch sử (Archive) chỉ lưu trữ cũ, hiếm khi INSERT/UPDATE/DELETE, thì nhiều Index có còn là thảm họa?
* **Trả lời:** **Không còn là thảm họa.** 
* Với bảng dạng Archive/Data Warehouse (OLAP), đặc thù hệ thống là **Heavy Read - Rare Write** (đọc rất nhiều để phân tích, tổng hợp, báo cáo; cực kỳ hiếm khi ghi). 
* Khi không có áp lực ghi thường xuyên, ta không bị ảnh hưởng bởi chi phí cập nhật cây B-Tree. Lúc này, việc đánh nhiều Index (thậm chí Composite Index và Covering Index) lại mang lại lợi ích vượt trội, giúp tăng tốc tối đa tốc độ tra cứu và trích xuất dữ liệu mà không sợ nghẽn thao tác ghi.
