-- ========================================================
-- HỆ THỐNG VÍ ĐIỆN TỬ PAYFLOW (TỐI ƯU HÓA HIỆU NĂNG DATABASE)
-- ========================================================

CREATE DATABASE IF NOT EXISTS payflow_db;
USE payflow_db;

-- 1. Cấu trúc bảng giao dịch
DROP TABLE IF EXISTS Transactions;

CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_type VARCHAR(20) NOT NULL, -- 'DEPOSIT', 'WITHDRAW', 'TRANSFER'
    created_at DATETIME NOT NULL
);

-- ========================================================
-- BƯỚC 1: TRUY VẤN CŨ GÂY NGHẼN HỆ THỐNG (LEGACY QUERY)
-- Vấn đề: Non-SARGable do dùng hàm YEAR() và MONTH() bọc quanh cột created_at.
-- Kế hoạch thực thi: type = ALL (Quét toàn bộ 5,000,000 dòng), CPU 100%, 45 giây.
-- ========================================================
EXPLAIN 
SELECT SUM(amount) AS total_deposit 
FROM Transactions 
WHERE transaction_type = 'DEPOSIT' 
  AND YEAR(created_at) = 2026 
  AND MONTH(created_at) = 6;


-- ========================================================
-- BƯỚC 2: TẠO COMPOSITE INDEX PHÙ HỢP VỚI MỆNH ĐỀ WHERE
-- Quy tắc Leftmost Prefix: 
-- 1. transaction_type (Đẳng thức '=') đặt trước.
-- 2. created_at (Khoảng phạm vi '>=, <') đặt sau.
-- ========================================================
CREATE INDEX idx_type_date ON Transactions(transaction_type, created_at);


-- ========================================================
-- BƯỚC 3: TRUY VẤN ĐÃ TỐI ƯU HÓA (OPTIMIZED SARGABLE QUERY)
-- Cải tiến: Thay hàm bằng khoảng thời gian (Range) từ 2026-06-01 đến 2026-07-01.
-- Kế hoạch thực thi: type = range / ref, tận dụng B-Tree Index tìm kiếm nhị phân.
-- ========================================================
EXPLAIN 
SELECT SUM(amount) AS total_deposit 
FROM Transactions 
WHERE transaction_type = 'DEPOSIT' 
  AND created_at >= '2026-06-01 00:00:00' 
  AND created_at < '2026-07-01 00:00:00';
