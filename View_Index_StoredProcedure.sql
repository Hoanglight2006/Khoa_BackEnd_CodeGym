-- =====================================================================
-- BÀI TẬP: LUYỆN TẬP SỬ DỤNG VIEW, INDEX, STORED PROCEDURE
-- =====================================================================

-- =====================================================================
-- BƯỚC 1: TẠO CƠ SỞ DỮ LIỆU DEMO
-- =====================================================================
CREATE DATABASE IF NOT EXISTS demo;
USE demo;


-- =====================================================================
-- BƯỚC 2: TẠO BẢNG PRODUCTS VÀ CHÈN DỮ LIỆU MẪU
-- =====================================================================
DROP TABLE IF EXISTS Products;

CREATE TABLE Products (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    productCode VARCHAR(20) NOT NULL,
    productName VARCHAR(100) NOT NULL,
    productPrice DECIMAL(12, 2) NOT NULL,
    productAmount INT NOT NULL DEFAULT 0,
    productDescription TEXT,
    productStatus VARCHAR(20) DEFAULT 'Available'
);

-- Chèn dữ liệu mẫu vào bảng Products
INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus)
VALUES
    ('P001', 'iPhone 15 Pro Max', 32990000.00, 50, 'Titanium tự nhiên 256GB', 'Available'),
    ('P002', 'Samsung Galaxy S24 Ultra', 29990000.00, 40, 'Màu xám Titan, bút S-Pen', 'Available'),
    ('P003', 'MacBook Air M2', 24500000.00, 30, 'Apple M2 8GB 256GB SSD', 'Available'),
    ('P004', 'Dell XPS 13', 27800000.00, 15, 'Intel Core i7 16GB 512GB', 'OutOfStock'),
    ('P005', 'Sony WH-1000XM5', 7990000.00, 100, 'Tai nghe chống ồn không dây', 'Available'),
    ('P006', 'iPad Pro M4', 28990000.00, 25, 'Màn hình OLED Ultra Retina XDR', 'Available');


-- =====================================================================
-- BƯỚC 3: THỰC HÀNH TẠO INDEX VÀ KHẢO SÁT VỚI EXPLAIN
-- =====================================================================

-- 3.1. Khảo sát câu truy vấn TRƯỚC KHI TẠO INDEX
-- Kết quả dự kiến: type = ALL (quét toàn bộ bảng), possible_keys = NULL
EXPLAIN SELECT * FROM Products WHERE productCode = 'P003';
EXPLAIN SELECT * FROM Products WHERE productName = 'iPhone 15 Pro Max' AND productPrice = 32990000.00;

-- 3.2. Tạo Unique Index trên cột productCode
CREATE UNIQUE INDEX idx_productCode ON Products(productCode);

-- 3.3. Tạo Composite Index trên 2 cột productName và productPrice
CREATE INDEX idx_name_price ON Products(productName, productPrice);

-- 3.4. Khảo sát câu truy vấn SAU KHI TẠO INDEX
-- Kết quả dự kiến với Unique Index: type = const (nhanh nhất), key = idx_productCode, rows = 1
EXPLAIN SELECT * FROM Products WHERE productCode = 'P003';

-- Kết quả dự kiến với Composite Index: type = ref, key = idx_name_price, rows = 1
EXPLAIN SELECT * FROM Products WHERE productName = 'iPhone 15 Pro Max' AND productPrice = 32990000.00;


-- =====================================================================
-- BƯỚC 4: THỰC HÀNH TẠO, SỬA ĐỔI VÀ XOÁ VIEW
-- =====================================================================

-- 4.1. Tạo View lấy thông tin: productCode, productName, productPrice, productStatus
CREATE VIEW view_products AS
SELECT 
    productCode, 
    productName, 
    productPrice, 
    productStatus
FROM 
    Products;

-- Truy vấn xem dữ liệu từ view:
SELECT * FROM view_products;

-- 4.2. Sửa đổi View (thêm cột productAmount và lọc sản phẩm còn hàng 'Available')
CREATE OR REPLACE VIEW view_products AS
SELECT 
    productCode, 
    productName, 
    productPrice, 
    productAmount,
    productStatus
FROM 
    Products
WHERE 
    productStatus = 'Available';

-- Kiểm tra lại sau khi sửa view:
SELECT * FROM view_products;

-- 4.3. Xoá View
DROP VIEW IF EXISTS view_products;


-- =====================================================================
-- BƯỚC 5: TẠO CÁC STORED PROCEDURE
-- =====================================================================

DELIMITER //

-- 5.1. Procedure lấy tất cả thông tin của tất cả sản phẩm
DROP PROCEDURE IF EXISTS sp_getAllProducts //
CREATE PROCEDURE sp_getAllProducts()
BEGIN
    SELECT * FROM Products;
END //


-- 5.2. Procedure thêm một sản phẩm mới
DROP PROCEDURE IF EXISTS sp_addProduct //
CREATE PROCEDURE sp_addProduct(
    IN p_code VARCHAR(20),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(12, 2),
    IN p_amount INT,
    IN p_desc TEXT,
    IN p_status VARCHAR(20)
)
BEGIN
    INSERT INTO Products (productCode, productName, productPrice, productAmount, productDescription, productStatus)
    VALUES (p_code, p_name, p_price, p_amount, p_desc, p_status);
END //


-- 5.3. Procedure sửa thông tin sản phẩm theo Id
DROP PROCEDURE IF EXISTS sp_updateProductById //
CREATE PROCEDURE sp_updateProductById(
    IN p_id INT,
    IN p_code VARCHAR(20),
    IN p_name VARCHAR(100),
    IN p_price DECIMAL(12, 2),
    IN p_amount INT,
    IN p_desc TEXT,
    IN p_status VARCHAR(20)
)
BEGIN
    UPDATE Products
    SET 
        productCode = p_code,
        productName = p_name,
        productPrice = p_price,
        productAmount = p_amount,
        productDescription = p_desc,
        productStatus = p_status
    WHERE 
        Id = p_id;
END //


-- 5.4. Procedure xoá sản phẩm theo Id
DROP PROCEDURE IF EXISTS sp_deleteProductById //
CREATE PROCEDURE sp_deleteProductById(IN p_id INT)
BEGIN
    DELETE FROM Products WHERE Id = p_id;
END //

DELIMITER ;


-- =====================================================================
-- BƯỚC 6: DEMO GỌI THỬ NGHIỆM CÁC STORED PROCEDURE
-- =====================================================================

-- 1. Xem toàn bộ sản phẩm ban đầu:
CALL sp_getAllProducts();

-- 2. Thêm mới 1 sản phẩm:
CALL sp_addProduct('P007', 'Bàn phím cơ Keychron Q1 Pro', 4500000.00, 20, 'Bàn phím cơ nhôm CNC không dây', 'Available');
CALL sp_getAllProducts();

-- 3. Cập nhật sản phẩm vừa thêm (giả sử Id = 7):
CALL sp_updateProductById(7, 'P007', 'Bàn phím cơ Keychron Q1 Pro V2', 4300000.00, 18, 'Bản nâng cấp switch Gateron Jupiter', 'Available');
CALL sp_getAllProducts();

-- 4. Xoá sản phẩm (Id = 7):
CALL sp_deleteProductById(7);
CALL sp_getAllProducts();
