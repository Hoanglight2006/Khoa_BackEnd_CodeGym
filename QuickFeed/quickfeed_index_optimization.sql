-- =====================================================================
-- HỆ THỐNG QUICKFEED: INDEX OPTIMIZATION SCRIPT
-- Vai trò: Database Administrator (DBA)
-- Mục tiêu: 
--   1. Khảo sát dung lượng Data Length vs Index Length (Storage Overhead)
--   2. Phẫu thuật loại bỏ 3 Index vô dụng / gây nghẽn Write: idx_content, idx_post_type, idx_is_visible
--   3. Bảo vệ 2 Index quan trọng: idx_user_id, idx_created_at
--   4. Đo lường và đối chiếu dung lượng trước & sau khi tối ưu
-- =====================================================================

CREATE DATABASE IF NOT EXISTS quickfeed_db;
USE quickfeed_db;

-- ---------------------------------------------------------------------
-- 1. SETUP SCHEMA LEGACY (Mô phỏng thảm họa over-indexing của dev cũ)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS Posts;

CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT,
    post_type VARCHAR(10),     -- 3 giá trị: 'TEXT', 'IMAGE', 'VIDEO'
    is_visible BOOLEAN DEFAULT 1, -- 2 giá trị: 1 (Hiện) hoặc 0 (Ẩn)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Thảm họa over-indexing: Đánh index vô tội vạ lên tất cả các cột
CREATE INDEX idx_user_id ON Posts(user_id);
CREATE INDEX idx_content ON Posts(content(255));      -- LỖI 1: Tốn ổ cứng khủng khiếp, text dài
CREATE INDEX idx_post_type ON Posts(post_type);        -- LỖI 2: Cardinality quá thấp (~3 giá trị)
CREATE INDEX idx_is_visible ON Posts(is_visible);      -- LỖI 3: Cardinality cực thấp (chỉ 0 và 1)
CREATE INDEX idx_created_at ON Posts(created_at);

-- ---------------------------------------------------------------------
-- 2. TẠO DỮ LIỆU MẪU ĐỂ KHẢO SÁT DUNG LƯỢNG
-- ---------------------------------------------------------------------
DELIMITER //
DROP PROCEDURE IF EXISTS generate_quickfeed_sample_data //
CREATE PROCEDURE generate_quickfeed_sample_data(IN total_rows INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    START TRANSACTION;
    WHILE i < total_rows DO
        INSERT INTO Posts (user_id, content, post_type, is_visible, created_at)
        VALUES (
            FLOOR(1 + RAND() * 10000),
            CONCAT('Đây là bài viết vi-blog số #', i, ' với nội dung chi tiết thảo luận về công nghệ, kiến trúc CSDL và các vấn đề liên quan đến hiệu năng hệ thống mạng xã hội QuickFeed.'),
            ELT(FLOOR(1 + RAND() * 3), 'TEXT', 'IMAGE', 'VIDEO'),
            IF(RAND() > 0.05, 1, 0), -- 95% là visible (1), 5% là hidden (0)
            NOW() - INTERVAL FLOOR(RAND() * 30) DAY
        );
        SET i = i + 1;
    END WHILE;
    COMMIT;
END //
DELIMITER ;

-- Khởi tạo 10,000 bản ghi mẫu để quan sát sự phình to của Index
CALL generate_quickfeed_sample_data(10000);


-- ---------------------------------------------------------------------
-- 3. ĐO LƯỜNG TÀI NGUYÊN TRƯỚC KHI TỐI ƯU (BEFORE OPTIMIZATION)
-- ---------------------------------------------------------------------

-- Cách 1: Xem trạng thái tổng quát bảng Posts
SHOW TABLE STATUS LIKE 'Posts';

-- Cách 2: Xem chi tiết các Index và Cardinality hiện tại
SHOW INDEX FROM Posts;

-- Cách 3: Truy vấn information_schema.TABLES tính chính xác Data & Index theo KB và MB
SELECT 
    table_schema AS Database_Name,
    table_name AS Table_Name,
    table_rows AS Estimated_Rows,
    ROUND(data_length / 1024, 2) AS Data_KB,
    ROUND(index_length / 1024, 2) AS Index_KB,
    ROUND(data_length / (1024 * 1024), 2) AS Data_MB,
    ROUND(index_length / (1024 * 1024), 2) AS Index_MB,
    ROUND((data_length + index_length) / (1024 * 1024), 2) AS Total_MB,
    ROUND((index_length / data_length) * 100, 2) AS Index_To_Data_Ratio_Percent
FROM 
    information_schema.TABLES
WHERE 
    table_schema = 'quickfeed_db' AND table_name = 'Posts';


-- ---------------------------------------------------------------------
-- 4. TIẾN HÀNH "PHẪU THUẬT": CẮT BỎ CÁC INDEX DƯ THỪA / VÔ DỤNG
-- ---------------------------------------------------------------------

-- Cắt bỏ LỖI 1: idx_content (Text dài, tốn RAM/Disk, tìm kiếm chuỗi nên dùng FULLTEXT)
ALTER TABLE Posts DROP INDEX idx_content;

-- Cắt bỏ LỖI 2: idx_post_type (Chỉ có 3 giá trị 'TEXT','IMAGE','VIDEO' -> Cardinality cực thấp)
ALTER TABLE Posts DROP INDEX idx_post_type;

-- Cắt bỏ LỖI 3: idx_is_visible (Chỉ có 0 và 1, 95% là 1 -> Optimizer sẽ quét Full Table Scan)
ALTER TABLE Posts DROP INDEX idx_is_visible;

-- Lưu ý: Giữ lại 2 Index quan trọng:
--   - idx_user_id: Độ chọn lọc cao, phục vụ load trang cá nhân của từng user.
--   - idx_created_at: Phục vụ sắp xếp bài viết Newsfeed theo thời gian mới nhất (ORDER BY created_at DESC).


-- ---------------------------------------------------------------------
-- 5. ĐO LƯỜNG VÀ ĐỐI CHIẾU DUNG LƯỢNG SAU KHI TỐI ƯU (AFTER OPTIMIZATION)
-- ---------------------------------------------------------------------

-- Tối ưu lại lưu trữ bảng sau khi Drop Index (giải phóng không gian phân mảnh InnoDB)
OPTIMIZE TABLE Posts;

-- Xem lại danh sách Index còn lại trên bảng Posts:
SHOW INDEX FROM Posts;

-- Truy vấn lại information_schema.TABLES để chứng minh Index_length đã sụt giảm mạnh:
SELECT 
    table_schema AS Database_Name,
    table_name AS Table_Name,
    table_rows AS Estimated_Rows,
    ROUND(data_length / 1024, 2) AS Data_KB,
    ROUND(index_length / 1024, 2) AS Index_KB,
    ROUND(data_length / (1024 * 1024), 2) AS Data_MB,
    ROUND(index_length / (1024 * 1024), 2) AS Index_MB,
    ROUND((data_length + index_length) / (1024 * 1024), 2) AS Total_MB,
    ROUND((index_length / data_length) * 100, 2) AS Index_To_Data_Ratio_Percent
FROM 
    information_schema.TABLES
WHERE 
    table_schema = 'quickfeed_db' AND table_name = 'Posts';
