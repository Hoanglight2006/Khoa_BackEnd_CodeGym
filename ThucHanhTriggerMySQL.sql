-- =====================================================================
-- BÀI THỰC HÀNH: SỬ DỤNG TRIGGER TRONG MYSQL
-- Cơ sở dữ liệu: company
-- =====================================================================

-- BƯỚC 1: TẠO CƠ SỞ DỮ LIỆU VÀ BẢNG EMPLOYEES
CREATE DATABASE IF NOT EXISTS company;
USE company;

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL
);


-- =====================================================================
-- BƯỚC 2: TẠO TRIGGER TỰ ĐỘNG PHÂN BỔ PHÒNG BAN THEO MỨC LƯƠNG
-- Thời điểm: BEFORE INSERT (trước khi bản ghi được ghi xuống đĩa)
-- Phạm vi: FOR EACH ROW (áp dụng cho từng dòng dữ liệu được thêm vào)
-- Quy tắc:
--   - Lương >= 5000: Phòng ban 'Management'
--   - Lương >= 3000: Phòng ban 'Sales'
--   - Còn lại (< 3000): Phòng ban 'Support'
-- =====================================================================

DELIMITER //

DROP TRIGGER IF EXISTS update_department //

CREATE TRIGGER update_department
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary >= 5000 THEN
        SET NEW.department = 'Management';
    ELSEIF NEW.salary >= 3000 THEN
        SET NEW.department = 'Sales';
    ELSE
        SET NEW.department = 'Support';
    END IF;
END //

DELIMITER ;


-- =====================================================================
-- BƯỚC 3: DEMO KIỂM THỬ HOẠT ĐỘNG CỦA TRIGGER
-- Thử chèn 3 nhân viên với department ban đầu là 'A'
-- =====================================================================

INSERT INTO employees (name, department, salary) 
VALUES 
    ('John Doe', 'A', 3500),       -- Kỳ vọng: department chuyển thành 'Sales'
    ('Jane Smith', 'A', 2000),      -- Kỳ vọng: department chuyển thành 'Support'
    ('David Johnson', 'A', 6000);   -- Kỳ vọng: department chuyển thành 'Management'

-- Kiểm tra kết quả trong bảng employees sau khi trigger xử lý:
SELECT * FROM employees;
