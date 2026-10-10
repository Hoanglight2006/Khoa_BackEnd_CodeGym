-- =====================================================================
-- BÀI THỰC HÀNH: LUYỆN TẬP SỬ DỤNG STORED PROCEDURE TRONG MYSQL
-- Cơ sở dữ liệu: classicmodels
-- =====================================================================

USE classicmodels;

-- =====================================================================
-- BƯỚC 1: TẠO STORED PROCEDURE ĐẦU TIÊN (LẤY TẤT CẢ KHÁCH HÀNG)
-- =====================================================================

-- Đổi ký tự kết thúc câu lệnh từ ; thành // để tránh ngắt lệnh sớm bên trong BEGIN...END
DELIMITER //

DROP PROCEDURE IF EXISTS `findAllCustomers` //

CREATE PROCEDURE findAllCustomers()
BEGIN
    SELECT * FROM customers;
END //

-- Đặt lại ký tự kết thúc câu lệnh về mặc định (;)
DELIMITER ;


-- =====================================================================
-- BƯỚC 2: GỌI STORED PROCEDURE
-- =====================================================================

-- Triệu gọi thủ tục findAllCustomers để lấy toàn bộ danh sách khách hàng:
CALL findAllCustomers();


-- =====================================================================
-- BƯỚC 3: SỬA / CẬP NHẬT STORED PROCEDURE
-- Trong MySQL không có câu lệnh ALTER PROCEDURE để sửa nội dung logic,
-- nên cách chuẩn là DROP PROCEDURE IF EXISTS rồi CREATE PROCEDURE lại.
-- =====================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS `findAllCustomers` //

CREATE PROCEDURE findAllCustomers()
BEGIN
    SELECT * FROM customers WHERE customerNumber = 175;
END //

DELIMITER ;


-- =====================================================================
-- BƯỚC 4: GỌI LẠI STORED PROCEDURE SAU KHI SỬA
-- =====================================================================

-- Gọi lại thủ tục, lúc này kết quả chỉ trả về khách hàng có customerNumber = 175
CALL findAllCustomers();
