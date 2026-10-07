-- ========================================================
-- HỆ THỐNG FLASHMART - BÁO CÁO DỮ LIỆU ĐÃ TỐI ƯU
-- ========================================================

CREATE DATABASE IF NOT EXISTS flashmart_db;
USE flashmart_db;

-- 1. Tạo cấu trúc bảng
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 2. Chèn dữ liệu mẫu
INSERT INTO Customers VALUES 
(1, 'Alice'), 
(2, 'Bob'), 
(3, 'Charlie'); -- Charlie chưa từng mua hàng

INSERT INTO Products VALUES 
(101, 'Laptop'), 
(102, 'Mouse'), 
(103, 'Keyboard'); -- Keyboard chưa từng được ai mua

INSERT INTO Orders VALUES 
(1001, 1, 101), 
(1002, 1, 102), 
(1003, 2, 101);

-- ========================================================
-- BÁO CÁO 1: DÀNH CHO GIÁM ĐỐC MARKETING
-- Yêu cầu: Tất cả khách hàng kèm số lượng đơn đã mua.
-- Khách chưa mua hiển thị total_orders = 0 để tặng Voucher 50%.
-- Giải pháp: LEFT JOIN giữ toàn vẹn bảng Customers, kết hợp
-- COUNT(o.order_id) để bỏ qua giá trị NULL của khách chưa mua.
-- ========================================================
SELECT 
    c.customer_id, 
    c.name, 
    COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- ========================================================
-- BÁO CÁO 2: DÀNH CHO GIÁM ĐỐC KHO VẬN (KỸ THUẬT ANTI-JOIN)
-- Yêu cầu: Danh sách các sản phẩm chưa từng được bán ra lần nào.
-- Giải pháp: LEFT JOIN từ Products sang Orders và lọc
-- WHERE o.order_id IS NULL để tìm các sản phẩm "mồ côi" giao dịch.
-- ========================================================
SELECT 
    p.product_id, 
    p.product_name
FROM Products p
LEFT JOIN Orders o ON p.product_id = o.product_id
WHERE o.order_id IS NULL;
