-- =====================================================================
-- BÀI THỰC HÀNH: TẠO CHỈ MỤC (INDEX) TRONG MYSQL
-- Cơ sở dữ liệu: classicmodels
-- =====================================================================

USE classicmodels;

-- =====================================================================
-- BƯỚC 1: KHẢO SÁT TRUY VẤN KHI CHƯA CÓ INDEX
-- =====================================================================

-- Tìm kiếm thông tin khách hàng theo tên mà chưa có chỉ mục:
SELECT * FROM customers WHERE customerName = 'Land of Toys Inc.';

-- Sử dụng EXPLAIN để xem kế hoạch thực thi (Execution Plan) của MySQL:
-- Kết quả dự kiến:
-- - type: ALL (Full table scan - phải quét toàn bộ bảng)
-- - possible_keys: NULL
-- - key: NULL
-- - rows: Quét qua toàn bộ số dòng trong bảng customers
EXPLAIN SELECT * FROM customers WHERE customerName = 'Land of Toys Inc.';


-- =====================================================================
-- BƯỚC 2: TẠO CHỈ MỤC ĐƠN (SINGLE-COLUMN INDEX)
-- =====================================================================

-- Thêm chỉ mục idx_customerName cho cột customerName:
ALTER TABLE customers ADD INDEX idx_customerName(customerName);

-- Kiểm tra lại kế hoạch thực thi với EXPLAIN:
-- Kết quả dự kiến:
-- - type: ref (Tra cứu qua index có giá trị tham chiếu)
-- - possible_keys: idx_customerName
-- - key: idx_customerName
-- - key_len: Chiều dài của index
-- - rows: 1 (Chỉ cần quét đúng 1 dòng thay vì toàn bộ bảng)
EXPLAIN SELECT * FROM customers WHERE customerName = 'Land of Toys Inc.';


-- =====================================================================
-- BƯỚC 3: TẠO CHỈ MỤC KẾT HỢP (COMPOSITE INDEX)
-- =====================================================================

-- Thêm chỉ mục kết hợp cho 2 cột contactFirstName và contactLastName:
ALTER TABLE customers ADD INDEX idx_full_name(contactFirstName, contactLastName);

-- Kiểm tra kế hoạch thực thi khi truy vấn theo các cột trong index:
EXPLAIN SELECT * FROM customers 
WHERE contactFirstName = 'Jean' OR contactFirstName = 'King';


-- =====================================================================
-- BƯỚC 4: XOÁ CHỈ MỤC (DROP INDEX)
-- =====================================================================

-- Xoá chỉ mục kết hợp vừa tạo:
ALTER TABLE customers DROP INDEX idx_full_name;

-- (Tuỳ chọn) Xoá chỉ mục đơn nếu muốn hoàn trả cấu trúc ban đầu:
-- ALTER TABLE customers DROP INDEX idx_customerName;
