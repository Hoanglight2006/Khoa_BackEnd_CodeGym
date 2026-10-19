-- ==============================================================
-- BÀI KIỂM TRA CUỐI MODULE: PHÁT TRIỂN ỨNG DỤNG WEB VỚI JSP & SERVLET
-- CƠ SỞ DỮ LIỆU: product_management_db
-- ==============================================================

CREATE DATABASE IF NOT EXISTS product_management_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE product_management_db;

-- 1. Tạo bảng products
CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DOUBLE NOT NULL,
    quantity INT NOT NULL
);

-- 2. Thêm dữ liệu mẫu ban đầu
INSERT INTO products (name, price, quantity) VALUES
('Laptop Dell XPS 15', 38990000, 15),
('iPhone 15 Pro Max 256GB', 29490000, 24),
('Bàn phím cơ Logitech G Pro X', 2890000, 50),
('Màn hình LG UltraWide 34 inch', 12500000, 10),
('Tai nghe chống ồn Sony WH-1000XM5', 7990000, 30),
('Chuột công thái học Logitech MX Master 3S', 2490000, 45);
