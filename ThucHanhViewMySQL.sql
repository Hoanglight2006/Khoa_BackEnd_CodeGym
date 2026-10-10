-- =====================================================================
-- BÀI THỰC HÀNH: LUYỆN TẬP TẠO VIEW TRONG MYSQL
-- Cơ sở dữ liệu: classicmodels
-- =====================================================================

USE classicmodels;

-- =====================================================================
-- BƯỚC 1: TẠO VIEW ĐẦU TIÊN
-- Tạo bảng ảo customer_views lấy 3 cột: customerNumber, customerName, phone
-- =====================================================================

CREATE VIEW customer_views AS 
SELECT 
    customerNumber, 
    customerName, 
    phone 
FROM 
    customers;


-- =====================================================================
-- BƯỚC 2: TRUY VẤN DỮ LIỆU TỪ VIEW
-- Sử dụng bảng ảo customer_views giống như một bảng thông thường
-- =====================================================================

SELECT * FROM customer_views;


-- =====================================================================
-- BƯỚC 3: CẬP NHẬT VIEW (CREATE OR REPLACE VIEW)
-- Bổ sung thêm contactFirstName, contactLastName và điều kiện lọc city = 'Nantes'
-- =====================================================================

CREATE OR REPLACE VIEW customer_views AS 
SELECT 
    customerNumber, 
    customerName, 
    contactFirstName, 
    contactLastName, 
    phone 
FROM 
    customers 
WHERE 
    city = 'Nantes';

-- Truy vấn lại view sau khi đã cập nhật:
SELECT * FROM customer_views;


-- =====================================================================
-- BƯỚC 4: XOÁ VIEW (DROP VIEW)
-- =====================================================================

DROP VIEW IF EXISTS customer_views;
