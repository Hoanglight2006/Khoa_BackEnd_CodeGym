-- =====================================================================
-- HỆ THỐNG SMARTFACTORY: INDEX RE-ENGINEERING SCRIPT
-- Vai trò: Database Optimization Expert
-- Mục tiêu: 
--   1. Đánh giá tác hại của Fat Covering Index đối với hệ thống IoT Real-time
--   2. Thay thế idx_fat_covering bằng Lean Index idx_lean_search(sensor_id, recorded_at)
--   3. Phân tích sự thay đổi trong EXPLAIN (Covering Index vs Table Lookup)
--   4. Đo lường sự sụt giảm của Index_length giải phóng ổ cứng Cloud AWS
-- =====================================================================

CREATE DATABASE IF NOT EXISTS smartfactory_db;
USE smartfactory_db;

-- ---------------------------------------------------------------------
-- 1. SETUP SCHEMA LEGACY & FAT COVERING INDEX
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS SensorLogs;

CREATE TABLE SensorLogs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sensor_id INT NOT NULL,
    recorded_at DATETIME NOT NULL,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    status VARCHAR(20) -- 'NORMAL', 'WARNING', 'CRITICAL'
);

-- "FAT INDEX" GÂY THẢM HỌA: Bao trùm toàn bộ các cột trong bảng
CREATE INDEX idx_fat_covering ON SensorLogs(sensor_id, recorded_at, temperature, humidity, status);


-- ---------------------------------------------------------------------
-- 2. TẠO DỮ LIỆU MẪU MÔ PHỎNG DÒNG DỮ LIỆU CẢM BIẾN IOT
-- ---------------------------------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS generate_sensor_data //
CREATE PROCEDURE generate_sensor_data(IN total_rows INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    START TRANSACTION;
    WHILE i < total_rows DO
        INSERT INTO SensorLogs (sensor_id, recorded_at, temperature, humidity, status)
        VALUES (
            FLOOR(100 + RAND() * 20),
            NOW() - INTERVAL FLOOR(RAND() * 86400) SECOND,
            ROUND(20.00 + (RAND() * 60.00), 2),
            ROUND(40.00 + (RAND() * 50.00), 2),
            ELT(FLOOR(1 + RAND() * 3), 'NORMAL', 'WARNING', 'CRITICAL')
        );
        SET i = i + 1;
    END WHILE;
    COMMIT;
END //
DELIMITER ;

-- Khởi tạo 20,000 dòng dữ liệu mẫu
CALL generate_sensor_data(20000);


-- ---------------------------------------------------------------------
-- 3. KHẢO SÁT HIỆU NĂNG VÀ TÀI NGUYÊN VỚI FAT INDEX (BEFORE)
-- ---------------------------------------------------------------------

-- Đo lường dung lượng Data vs Index của bảng SensorLogs
SELECT 
    table_name AS Table_Name,
    ROUND(data_length / 1024, 2) AS Data_KB,
    ROUND(index_length / 1024, 2) AS Index_KB,
    ROUND(data_length / (1024 * 1024), 2) AS Data_MB,
    ROUND(index_length / (1024 * 1024), 2) AS Index_MB,
    ROUND((index_length / data_length) * 100, 2) AS Index_To_Data_Percent
FROM 
    information_schema.TABLES
WHERE 
    table_schema = 'smartfactory_db' AND table_name = 'SensorLogs';

-- Khảo sát câu truy vấn Dashboard:
-- Kết quả dự kiến: Extra = 'Using index' (Covering Index - không cần đọc bảng gốc)
EXPLAIN SELECT temperature, humidity, status 
FROM SensorLogs
WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';


-- ---------------------------------------------------------------------
-- 4. TỐI ƯU HÓA: CẮT BỎ FAT INDEX VÀ THIẾT KẾ LEAN INDEX
-- ---------------------------------------------------------------------

-- Bước 4.1: Xóa bỏ Fat Index cồng kềnh
ALTER TABLE SensorLogs DROP INDEX idx_fat_covering;

-- Bước 4.2: Tạo Lean Index (chỉ giữ 2 cột phục vụ lọc điều kiện WHERE/ORDER BY)
CREATE INDEX idx_lean_search ON SensorLogs(sensor_id, recorded_at);

-- Tối ưu lại phân bổ bộ nhớ InnoDB sau khi thay đổi Index:
OPTIMIZE TABLE SensorLogs;


-- ---------------------------------------------------------------------
-- 5. KHẢO SÁT HIỆU NĂNG VÀ TÀI NGUYÊN SAU TỐI ƯU (AFTER)
-- ---------------------------------------------------------------------

-- Khảo sát lại câu truy vấn Dashboard:
-- Kết quả dự kiến:
--   - key: idx_lean_search
--   - type: range (vẫn cực kỳ tối ưu vì dùng index lọc sensor_id và recorded_at)
--   - Extra: NULL hoặc Using index condition (không còn 'Using index' thuần túy vì phải Bookmark Lookup lấy temperature, humidity, status)
EXPLAIN SELECT temperature, humidity, status 
FROM SensorLogs
WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';

-- Đo lường lại dung lượng lưu trữ: Chứng minh Index_length đã giảm mạnh ~70-75%
SELECT 
    table_name AS Table_Name,
    ROUND(data_length / 1024, 2) AS Data_KB,
    ROUND(index_length / 1024, 2) AS Index_KB,
    ROUND(data_length / (1024 * 1024), 2) AS Data_MB,
    ROUND(index_length / (1024 * 1024), 2) AS Index_MB,
    ROUND((index_length / data_length) * 100, 2) AS Index_To_Data_Percent
FROM 
    information_schema.TABLES
WHERE 
    table_schema = 'smartfactory_db' AND table_name = 'SensorLogs';
