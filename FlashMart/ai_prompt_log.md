# NHẬT KÝ TƯƠNG TÁC VÀ TỐI ƯU HÓA TRUY VẤN VỚI AI (AI PROMPT LOG)

**Dự án:** Sàn thương mại điện tử FlashMart  
**Vai trò:** Data Engineer (Học viên) & SQL Tuning Assistant (AI)  

---

## Phiên 1: Phân tích hành vi mặc định của JOIN và lý thuyết tập hợp (Set Theory)

### Câu hỏi (User Prompt):
> Trong cơ sở dữ liệu MySQL, mặc định từ khóa `JOIN` (khi không ghi rõ `LEFT` hay `RIGHT`) sẽ hoạt động như thế nào? Nó sẽ bỏ qua hay giữ lại các bản ghi không có sự trùng khớp ở cả hai bảng? Giải thích theo lý thuyết tập hợp (Venn Diagram).

### Phản hồi từ AI:
Trong chuẩn SQL và MySQL:
- Khi viết từ khóa `JOIN` đơn thuần (hoặc `CROSS JOIN` có điều kiện `ON`), MySQL mặc định hiểu là **`INNER JOIN`**.
- **Nguyên lý tập hợp (Venn Diagram):** `INNER JOIN` đại diện cho phần **giao nhau** ($A \cap B$) giữa hai tập hợp bảng Trái ($A$) và bảng Phải ($B$). Chỉ những bản ghi thỏa mãn điều kiện kết nối (`A.key = B.key`) mới xuất hiện trong kết quả.
- **Hệ quả với FlashMart:** 
  - Khách hàng Charlie chưa có đơn hàng trong bảng `Orders` nên không thuộc tập giao $\rightarrow$ bị loại bỏ hoàn toàn khỏi báo cáo Marketing.
  - Sản phẩm Keyboard chưa ai mua nên không có bản ghi trong bảng `Orders` $\rightarrow$ bị loại bỏ khỏi báo cáo Kho vận.

---

## Phiên 2: Phân tích hàm COUNT() kết hợp GROUP BY trong phép LEFT JOIN

### Câu hỏi (User Prompt):
> Khi tôi sử dụng `LEFT JOIN` và đếm số lượng đơn hàng bằng hàm `COUNT`, tôi nên dùng `COUNT(*)` hay `COUNT(o.order_id)`? Sự khác biệt khi kết quả trả về `NULL` là gì?

### Phản hồi từ AI:
- **`COUNT(*)`**: Đếm số lượng hàng (rows) trong nhóm kết quả sau khi kết nối bảng. Vì `LEFT JOIN` vẫn sinh ra 1 hàng cho khách hàng chưa mua hàng (với các cột của `Orders` mang giá trị `NULL`), `COUNT(*)` vẫn tính hàng đó là 1. Điều này dẫn đến sai lệch nghiêm trọng: khách chưa mua bị báo cáo là đã có 1 đơn.
- **`COUNT(column_name)`**: Chỉ đếm các ô dữ liệu có giá trị khác `NULL` (`NOT NULL`). Đối với Charlie, do `o.order_id` là `NULL`, hàm `COUNT(o.order_id)` sẽ bỏ qua và trả về kết quả chính xác là `0`.
- **Kết luận:** Luôn chỉ định cột khóa chính của bảng phụ (`o.order_id`) bên trong hàm `COUNT()` khi kết hợp với `LEFT JOIN`.

---

## Phiên 3: So sánh hiệu năng giữa Anti-Join (LEFT JOIN ... IS NULL) và NOT IN / NOT EXISTS

### Câu hỏi (User Prompt):
> Hãy phân tích hiệu năng (Performance) của việc dùng `LEFT JOIN ... WHERE IS NULL` so với việc dùng subquery `NOT IN` hoặc `NOT EXISTS` khi muốn tìm kiếm các bản ghi không tồn tại trong bảng khác.

### Phản hồi từ AI:
1. **Rủi ro với `NOT IN`:**
   - Nếu tập kết quả của subquery chứa dù chỉ một giá trị `NULL`, toàn bộ biểu thức `NOT IN` sẽ trả về tập rỗng (do logic 3 trạng thái của SQL: `True`, `False`, `Unknown`).
   - Cần bắt buộc thêm điều kiện `WHERE column IS NOT NULL` trong subquery.
2. **So sánh `LEFT JOIN ... WHERE IS NULL` vs `NOT EXISTS`:**
   - Cả hai đều an toàn với giá trị `NULL`.
   - Trong MySQL hiện đại (từ 5.7 trở lên), bộ tối ưu hóa truy vấn (**Query Optimizer**) thường chuyển đổi (rewrite) câu lệnh `LEFT JOIN ... WHERE IS NULL` và `NOT EXISTS` về cùng một kế hoạch thực thi tối ưu (Anti-Join Execution Plan).
   - Tuy nhiên, `LEFT JOIN ... WHERE IS NULL` đòi hỏi tạo bảng kết nối trước khi lọc, trong khi `NOT EXISTS` có thể dừng ngay khi tìm thấy bản ghi trùng khớp đầu tiên (Short-circuit evaluation), giúp tối ưu bộ nhớ hơn khi bảng phụ cực lớn.

---

## Phiên 4: Cơ chế tối ưu hóa MySQL Optimizer với thuật toán Nested-Loop Join

### Câu hỏi (User Prompt):
> MySQL Optimizer xử lý các câu lệnh `JOIN` như thế nào thông qua thuật toán Nested-Loop Join? Tại sao thứ tự chọn Driving Table (bảng điều hướng) lại quyết định tốc độ truy vấn?

### Phản hồi từ AI:
1. **Simple Nested-Loop Join (NLJ):**
   - Hoạt động tương tự hai vòng lặp lồng nhau: Duyệt từng dòng của Outer Table (Driving Table), sau đó quét Inner Table để tìm dòng khớp.
   - Nếu Inner Table không có index, chi phí là $O(M \times N)$ (rất chậm với bảng lớn).
2. **Block Nested-Loop Join (BNL) & Hash Join (MySQL 8.0.18+):**
   - MySQL cấp phát một vùng nhớ gọi là **Join Buffer**. Một khối (block) nhiều dòng từ Outer Table được nạp vào buffer để so sánh cùng lúc với Inner Table trong một lần quét, giảm số lượt đọc ổ đĩa I/O.
   - Từ MySQL 8.0.18, MySQL đã thay thế hoàn toàn BNL bằng **Hash Join** khi không có index, tăng tốc độ xử lý lên nhiều lần.
3. **Ý nghĩa của Driving Table:**
   - Trong `LEFT JOIN`, bảng bên trái bắt buộc phải là Driving Table ban đầu. Optimizer không thể tự ý đảo ngược thứ tự bảng trừ khi có điều kiện lọc triệt tiêu `NULL` trong mệnh đề `WHERE` (biến thành INNER JOIN ngầm).
   - Chọn Driving Table có ít bản ghi sau khi lọc sẽ giảm kích thước vòng lặp ngoài, giúp tối ưu thời gian thực thi.
