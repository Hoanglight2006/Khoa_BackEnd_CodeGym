# NHẬT KÝ TRA CỨU AI (AI PROMPT LOG)
**Dự án:** QuickFeed Platform - Tối ưu hóa Index & Tài nguyên lưu trữ  
**Học viên:** Database Administrator (DBA)  
**Vai trò AI:** Storage & Performance Profiler  

---

### Prompt 1: Tác hại của việc tạo Index trên cột TEXT và cột BOOLEAN
* **Người dùng (Học viên):**
  > Trong MySQL, nếu tôi tạo Index trên một cột chứa văn bản dài (TEXT) và một cột kiểu BOOLEAN (0 và 1), thì điều này gây hại như thế nào đến bộ nhớ RAM, dung lượng Disk và bộ tối ưu hóa (Query Optimizer)?
* **Phản hồi từ AI:**
  1. **Bộ nhớ RAM & Dung lượng Disk:**
     * Cột `TEXT(255)` tạo tiền tố 255 bytes cho mỗi khóa index. Nếu bảng có hàng triệu dòng, cây B-Tree phình to hàng trăm Megabyte, chiếm dụng toàn bộ bộ đệm `innodb_buffer_pool_size`, đẩy các trang dữ liệu thường dùng khác ra khỏi RAM.
     * Cột `BOOLEAN` dù chỉ 1 byte nhưng vẫn tạo một cây B-Tree riêng biệt, tiêu tốn các Index Pages trên đĩa chỉ để lưu trữ thông tin có độ phân biệt gần như bằng không.
  2. **Bộ tối ưu hóa (Query Optimizer):**
     * MySQL Optimizer phải tốn thời gian tính toán chi phí (Cost-Based Optimizer). Khi một cột có độ chọn lọc quá thấp (như Boolean), Optimizer thường quyết định bỏ qua Index và chọn Full Table Scan, khiến chi phí duy trì Index trở nên vô nghĩa.

---

### Prompt 2: Tại sao MySQL bỏ qua Index trên cột có tỉ lệ phân bố chênh lệch cao
* **Người dùng (Học viên):**
  > Tại sao khi tôi truy vấn `SELECT * FROM Posts WHERE is_visible = 1` trên một bảng có hàng triệu dòng (trong đó 99% bài viết là visible = 1), MySQL lại quyết định quét toàn bảng (Full Table Scan) thay vì sử dụng Index `idx_is_visible` đã tạo?
* **Phản hồi từ AI:**
  * **Cơ chế Cost-based Optimizer:** Khi tìm kiếm `is_visible = 1` (chiếm 99% dữ liệu), nếu dùng Index:
    1. MySQL phải duyệt cây B-Tree để tìm 990,000 con trỏ (Primary Key).
    2. Sau đó thực hiện 990,000 lần đọc ngẫu nhiên (Random Disk I/O) vào Clustered Index để lấy toàn bộ cột dữ liệu (`SELECT *`).
  * Trong khi đó, **Full Table Scan** chỉ cần đọc tuần tự (Sequential Read) từ đầu đến cuối bảng qua các Data Pages một lần duy nhất.
  * Vì Sequential I/O nhanh hơn Random I/O gấp nhiều lần, MySQL Optimizer xác định chi phí duyệt Index cao hơn nhiều so với Full Table Scan nên chủ động bỏ qua Index.

---

### Prompt 3: Truy vấn đo lường Data Length và Index Length từ information_schema
* **Người dùng (Học viên):**
  > Hãy cho tôi xem truy vấn SQL sử dụng bảng information_schema.TABLES để in ra kích thước Data và kích thước Index của bảng 'Posts' tính theo đơn vị Megabyte (MB).
* **Phản hồi từ AI:**
  ```sql
  SELECT 
      table_name,
      ROUND(data_length / (1024 * 1024), 2) AS data_mb,
      ROUND(index_length / (1024 * 1024), 2) AS index_mb,
      ROUND((data_length + index_length) / (1024 * 1024), 2) AS total_mb,
      ROUND((index_length / data_length) * 100, 2) AS index_to_data_ratio
  FROM 
      information_schema.TABLES
  WHERE 
      table_schema = 'quickfeed_db' AND table_name = 'Posts';
  ```

---

### Prompt 4: Giải pháp tìm kiếm bài viết dài không gây phình to B-Tree Index
* **Người dùng (Học viên):**
  > Nếu muốn tìm kiếm từ khóa bên trong cột content (kiểu TEXT) mà không bị tốn quá nhiều dung lượng như B-Tree Index, tôi nên sử dụng cơ chế nào của MySQL?
* **Phản hồi từ AI:**
  * Thay vì dùng B-Tree prefix index (`INDEX(content(255))`), giải pháp tối ưu là sử dụng **FULLTEXT INDEX** kết hợp hàm `MATCH(...) AGAINST(...)`:
    ```sql
    ALTER TABLE Posts ADD FULLTEXT INDEX ft_idx_content(content);
    ```
  * **Lợi ích:** Full-Text Search sử dụng cấu trúc **Inverted Index** (danh mục từ ngữ nghịch đảo), chỉ lập chỉ mục cho các từ ngữ thực tế (bỏ qua stop words) thay vì lưu trữ mù quáng chuỗi ký tự, giúp kích thước chỉ mục nhỏ hơn, hỗ trợ tìm kiếm ngữ nghĩa theo cụm từ và độ liên quan tốt hơn nhiều.

---

### Prompt 5: Cấu trúc lưu trữ trang dữ liệu của InnoDB (Data Pages vs Index Pages)
* **Người dùng (Học viên):**
  > Hãy giải thích chi tiết cơ chế lưu trữ của InnoDB Storage Engine: Sự khác nhau giữa Data Pages và Index Pages, hiện tượng Page Split xảy ra như thế nào khi INSERT?
* **Phản hồi từ AI:**
  1. **Kích thước Page:** InnoDB phân chia không gian lưu trữ đĩa thành các khối có kích thước cố định là **16KB (Page)**.
  2. **Data Pages (Clustered Index):** Chứa các dòng dữ liệu hoàn chỉnh, sắp xếp vật lý theo khóa chính (`PRIMARY KEY`).
  3. **Index Pages (Secondary Index):** Chỉ chứa giá trị của cột được đánh chỉ mục và giá trị của khóa chính (`Primary Key`) để trỏ ngược lại.
  4. **Hiện tượng Page Split:** Mặc định mỗi Page chứa được một số lượng phần tử nhất định. Khi chèn thêm một phần tử vào giữa cây B-Tree mà Page đó đã đầy 100%:
     * InnoDB buộc phải cấp phát một Page mới (16KB).
     * Di chuyển khoảng 50% dữ liệu từ trang cũ sang trang mới để giữ cân bằng.
     * Cập nhật lại con trỏ ở Page cha cấp trên.
     * Quá trình này đòi hỏi nhiều thao tác I/O ngẫu nhiên và khóa trang, gây suy giảm nghiêm trọng tốc độ ghi khi có quá nhiều Index cần cập nhật đồng thời.
