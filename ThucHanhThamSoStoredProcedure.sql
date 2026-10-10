-- =====================================================================
-- BÀI THỰC HÀNH: TRUYỀN THAM SỐ VÀO STORED PROCEDURE TRONG MYSQL
-- Các loại tham số: IN, OUT, INOUT
-- Cơ sở dữ liệu: classicmodels
-- =====================================================================

USE classicmodels;

-- =====================================================================
-- PHẦN 1: THAM SỐ LOẠI IN
-- Đặc điểm: Là chế độ mặc định, dùng để truyền dữ liệu từ ngoài vào trong procedure.
-- Trong procedure chỉ đọc/dùng giá trị này, không làm thay đổi giá trị gốc ở ngoài.
-- =====================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS `getCusById` //

CREATE PROCEDURE getCusById(IN cusNum INT)
BEGIN
    SELECT * FROM customers WHERE customerNumber = cusNum;
END //

DELIMITER ;

-- Gọi Stored Procedure với tham số IN (tìm khách hàng có mã 175):
CALL getCusById(175);


-- =====================================================================
-- PHẦN 2: THAM SỐ LOẠI OUT
-- Đặc điểm: Dùng để trả dữ liệu từ trong procedure ra ngoài (hoạt động giống tham chiếu).
-- Khi truyền vào, biến có giá trị ban đầu là NULL. Khi gọi cần dùng biến session có tiền tố @.
-- =====================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS `GetCustomersCountByCity` //

CREATE PROCEDURE GetCustomersCountByCity(
    IN in_city VARCHAR(50),
    OUT total INT
)
BEGIN
    SELECT COUNT(customerNumber) 
    INTO total 
    FROM customers 
    WHERE city = in_city;
END //

DELIMITER ;

-- Gọi Stored Procedure với tham số OUT:
-- Biến @total sẽ nhận kết quả đếm số khách hàng ở thành phố 'Lyon'
CALL GetCustomersCountByCity('Lyon', @total);

-- Xem giá trị của biến @total sau khi gọi procedure:
SELECT @total AS TotalCustomersInLyon;


-- =====================================================================
-- PHẦN 3: THAM SỐ LOẠI INOUT
-- Đặc điểm: Kết hợp cả IN và OUT.
-- Biến truyền vào có thể mang giá trị sẵn từ bên ngoài, sau đó procedure xử lý 
-- và cập nhật lại giá trị mới vào chính biến đó.
-- =====================================================================

DELIMITER //

DROP PROCEDURE IF EXISTS `SetCounter` //

CREATE PROCEDURE SetCounter(
    INOUT counter INT,
    IN inc INT
)
BEGIN
    SET counter = counter + inc;
END //

DELIMITER ;

-- Khởi tạo biến session @counter = 1
SET @counter = 1;

-- Gọi lần 1: 1 + 1 = 2
CALL SetCounter(@counter, 1);

-- Gọi lần 2: 2 + 1 = 3
CALL SetCounter(@counter, 1);

-- Gọi lần 3: 3 + 5 = 8
CALL SetCounter(@counter, 5);

-- Kiểm tra giá trị cuối cùng của biến @counter (kết quả mong đợi: 8):
SELECT @counter AS FinalCounter;
