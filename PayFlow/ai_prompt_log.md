# NHẬT KÝ TƯƠNG TÁC TỐI ƯU HÓA HIỆU NĂNG VỚI AI (AI PROMPT LOG)

**Dự án:** Ví điện tử PayFlow  
**Vai trò:** Database Performance Engineer (Học viên) & Database Tuning Assistant (AI)  

---

## Phiên 1: Vấn đề Non-SARGable và nguyên nhân Full Table Scan

### Câu hỏi (User Prompt):
> Trong MySQL, nếu tôi tạo Index cho một cột ngày tháng, nhưng trong mệnh đề WHERE tôi lại viết `WHERE YEAR(col) = 2026 AND MONTH(col) = 6`, tại sao MySQL lại từ chối sử dụng Index và phải quét toàn bộ bảng (Full Table Scan)? Thuật ngữ SARGable nghĩa là gì?

### Phản hồi từ AI:
- **Khái niệm SARGable (Search Argument Able):** Là khả năng một biểu thức điều kiện trong mệnh đề `WHERE` có thể tận dụng trực tiếp cấu trúc cây B-Tree của Index để thực hiện tìm kiếm nhị phân (Index Seek) mà không cần quét tuần tự từng dòng.
- **Tại sao bọc hàm làm mất SARGable:**
  - B-Tree Index lưu trữ giá trị thô nguyên bản của cột ngày tháng (ví dụ: `'2026-06-15 10:30:00'`).
  - Khi bạn bọc hàm `YEAR(created_at)`, MySQL không thể đoán trước giá trị đầu ra của hàm nếu không tính toán nó. Do đó, Database bắt buộc phải duyệt qua toàn bộ 5,000,000 dòng, gọi hàm `YEAR()` và `MONTH()` trên từng dòng một để kiểm tra điều kiện.
  - Quá trình này ngốn sạch tài nguyên CPU và biến một Index có sẵn thành vô dụng.

---

## Phiên 2: Nguyên lý thiết kế Composite Index và quy tắc Leftmost Prefix

### Câu hỏi (User Prompt):
> Khi thiết kế một Composite Index trong MySQL cho hai cột `(transaction_type, created_at)`, thứ tự các cột trong Index có quan trọng không? Tôi nên đặt cột nào đứng trước để có hiệu suất lọc dữ liệu tốt nhất?

### Phản hồi từ AI:
Thứ tự cột trong Composite Index mang tính quyết định tuyệt đối theo **Quy tắc tiền tố bên trái (Leftmost Prefix Rule)**:
1. **Nguyên lý sắp xếp của B-Tree đa cột:** B-Tree sẽ sắp xếp dữ liệu theo cột đầu tiên trước. Chỉ khi các giá trị ở cột đầu tiên bằng nhau, nó mới sắp xếp tiếp theo cột thứ hai.
2. **Quy tắc vàng:** **"Equality First, Range Second"** (Cột có phép so sánh bằng `=` đặt trước, cột so sánh khoảng phạm vi `>=`, `<`, `BETWEEN` đặt sau).
   - Nếu tạo Index `(created_at, transaction_type)`: Sau khi quét phạm vi ngày tháng (`created_at >= ... AND created_at < ...`), thứ tự sắp xếp của `transaction_type` bị phá vỡ. MySQL chỉ dùng được Index cho việc lọc ngày, còn điều kiện `transaction_type = 'DEPOSIT'` phải lọc lại bằng CPU.
   - Nếu tạo Index `(transaction_type, created_at)`: MySQL tìm đến nhánh `transaction_type = 'DEPOSIT'`, sau đó trong toàn bộ tập con đó, các mốc thời gian `created_at` đã được sắp xếp tuần tự liên tục $\rightarrow$ MySQL thực hiện quét phạm vi (Range Scan) cực kỳ nhanh chóng.

---

## Phiên 3: Đo lường thời gian thực thi với Profiling và giải mã chỉ số EXPLAIN

### Câu hỏi (User Prompt):
> Làm thế nào để tôi có thể đo lường chi tiết thời gian thực thi (Execution Time) của câu lệnh trong MySQL? Trong kết quả `EXPLAIN`, cột `Extra` hiện `'Using index condition'` khác gì với `'Using index'`?

### Phản hồi từ AI:
1. **Đo thời gian thực thi với MySQL Profiling:**
   ```sql
   SET profiling = 1;
   -- Chạy câu lệnh SQL cần đo
   SHOW PROFILES;
   SHOW PROFILE FOR QUERY 1; -- Xem chi tiết thời gian qua từng giai đoạn (parsing, opening tables, executing, cpu time)
   ```
2. **Phân biệt `Using index condition` vs `Using index`:**
   - **`Using index` (Covering Index):** Toàn bộ các cột cần lấy trong câu `SELECT` đều nằm ngay trên cây Index. MySQL không cần đọc vào đĩa dữ liệu bảng gốc (Clustered Index/Data Page), mang lại hiệu năng cao nhất.
   - **`Using index condition` (Index Condition Pushdown - ICP):** MySQL đẩy điều kiện lọc xuống tầng Storage Engine (InnoDB) để lọc bớt các dòng không khớp ngay trong cây Index trước khi đọc bảng dữ liệu gốc, giúp giảm số lần đọc I/O đĩa.

---

## Phiên 4: Cấu trúc B+Tree, sự khác biệt giữa Index Seek và Index Scan, và chi phí Write Amplification

### Câu hỏi (User Prompt):
> Hãy phân tích sự khác nhau giữa Index Seek và Index Scan trong cấu trúc B+Tree của InnoDB. Nếu một bảng có tần suất ghi (INSERT/UPDATE/DELETE) cao, việc tạo thêm nhiều Index sẽ gây ra rủi ro gì?

### Phản hồi từ AI:
1. **Index Seek vs Index Scan:**
   - **Index Seek:** Bắt đầu từ node gốc (Root Node) của cây B+Tree, di chuyển qua các node nhánh theo phép tìm kiếm nhị phân với độ phức tạp $O(\log N)$ để trỏ thẳng tới bản ghi đầu tiên thỏa mãn. Đây là cơ chế nhanh nhất.
   - **Index Scan:** Duyệt tuần tự qua danh sách liên kết kép (Doubly Linked List) ở tầng lá (Leaf Nodes) của cây B+Tree. Mặc dù vẫn nhanh hơn quét toàn bảng (vì Index nhỏ hơn bảng dữ liệu), nhưng vẫn phải duyệt nhiều trang nhớ.
2. **Chi phí khuếch đại ghi (Write Amplification):**
   - Mỗi lệnh `INSERT`, `UPDATE` hoặc `DELETE` không chỉ sửa đổi dữ liệu bảng chính mà còn phải cập nhật lại tất cả các cây Index phụ (Secondary Indexes) tương ứng.
   - Khi các trang lá của B-Tree bị đầy, thao tác ghi sẽ kích hoạt hiện tượng **Phân tách trang (Page Split)**, làm tốn I/O đĩa và phân mảnh dữ liệu.
   - Quá nhiều Index gây cạnh tranh khóa (Lock Contention) trên buffer pool và gia tăng tỷ lệ Deadlock khi có hàng nghìn giao dịch đồng thời.
