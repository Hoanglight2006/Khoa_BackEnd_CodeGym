# Báo Cáo Phân Tích Kế Hoạch Thực Thi (EXPLAIN Analysis)

| Chỉ số EXPLAIN | Trước khi Tối ưu (Legacy) | Sau khi Tối ưu (Refactored) | Ý nghĩa Kỹ thuật |
| :--- | :--- | :--- | :--- |
| **type** | `ALL` | `range` | Chuyển từ Quét toàn bảng (Full Table Scan) sang Quét phạm vi trên Index. |
| **possible_keys**| `NULL` | `idx_type_date` | Hệ thống đã nhận diện được Index tiềm năng. |
| **key** | `NULL` | `idx_type_date` | Index được chọn chính xác để thực thi truy vấn. |
| **rows** | `5,000,000` (100% bảng) | `~12,000` (< 0.3% bảng) | Giảm số lượng dòng cần duyệt lên tới hơn 400 lần. |
| **Extra** | `Using where` | `Using index condition` | Tận dụng Index Condition Pushdown (ICP) lọc ngay tại tầng Storage Engine. |

### Đánh giá:
Truy vấn cũ bọc hàm `YEAR()` và `MONTH()` quanh cột `created_at` (Non-SARGable), khiến MySQL phải tính toán hàm trên từng dòng dữ liệu và ép buộc Full Table Scan, đẩy CPU lên 100%.

Bằng việc tạo Composite Index `(transaction_type, created_at)` và viết lại điều kiện thời gian dưới dạng Range (`>= '2026-06-01'` và `< '2026-07-01'`), cây B-Tree thực hiện tìm kiếm nhị phân chính xác. Thời gian truy vấn giảm từ 45 giây xuống dưới 0.05 giây, triệt tiêu hoàn toàn nghẽn tài nguyên và hiện tượng khóa bảng.
