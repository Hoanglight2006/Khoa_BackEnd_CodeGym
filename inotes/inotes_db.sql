-- ==============================================================
-- CƠ SỞ DỮ LIỆU: inotes_db
-- Ứng dụng: Quản lý ghi chú cá nhân iNotes
-- ==============================================================

CREATE DATABASE IF NOT EXISTS inotes_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE inotes_db;

-- 1. Bảng note_type (Thể loại ghi chú)
CREATE TABLE IF NOT EXISTS note_type (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);

-- 2. Bảng notes (Danh sách ghi chú)
CREATE TABLE IF NOT EXISTS notes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    type_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_notes_type FOREIGN KEY (type_id) REFERENCES note_type(id) ON DELETE SET NULL
);

-- Dữ liệu mẫu bảng note_type
INSERT INTO note_type (id, name, description) VALUES
(1, 'Cá nhân', 'Ghi chú cho các kế hoạch, thói quen và việc riêng tư'),
(2, 'Công việc', 'Nhiệm vụ, lịch họp và công việc văn phòng'),
(3, 'Học tập', 'Tài liệu, bài tập và kiến thức ôn tập chuyên môn')
ON DUPLICATE KEY UPDATE name=VALUES(name), description=VALUES(description);

-- Dữ liệu mẫu bảng notes
INSERT INTO notes (id, title, content, type_id) VALUES
(1, 'Họp giao ban đầu tuần', 'Thảo luận tiến độ dự án quý 2 và phân công công việc cụ thể cho từng thành viên trong nhóm.', 2),
(2, 'Ôn tập Design Pattern Servlet', 'Xem lại cấu trúc MVC, Strategy Pattern và cách triển khai HttpServletRequest/HttpServletResponse trong Jakarta EE.', 3),
(3, 'Kế hoạch tập gym', 'Lịch tập 4 buổi/tuần: Ngực - Tay sau, Lưng - Tay trước, Chân - Bụng, Nghỉ ngơi cuối tuần.', 1),
(4, 'Báo cáo doanh số tháng', 'Tổng hợp số liệu từ các phòng ban và xuất báo cáo PDF gửi ban giám đốc trước ngày 25.', 2)
ON DUPLICATE KEY UPDATE title=VALUES(title), content=VALUES(content), type_id=VALUES(type_id);
