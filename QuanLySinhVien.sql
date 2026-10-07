CREATE DATABASE IF NOT EXISTS QuanLySinhVien;
USE QuanLySinhVien;

CREATE TABLE Class (
    ClassID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ClassName VARCHAR(60) NOT NULL,
    StartDate DATETIME NOT NULL,
    Status BIT
);

CREATE TABLE Student (
    StudentID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    StudentName VARCHAR(30) NOT NULL,
    Address VARCHAR(50),
    Phone VARCHAR(20),
    Status BIT,
    ClassID INT NOT NULL,
    FOREIGN KEY (ClassID) REFERENCES Class (ClassID)
);

CREATE TABLE Subject (
    SubID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    SubName VARCHAR(30) NOT NULL,
    Credit TINYINT NOT NULL DEFAULT 1 CHECK (Credit >= 1),
    Status BIT DEFAULT 1
);

CREATE TABLE Mark (
    MarkID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    SubID INT NOT NULL,
    StudentID INT NOT NULL,
    Mark FLOAT DEFAULT 0 CHECK (Mark BETWEEN 0 AND 100),
    ExamTimes TINYINT DEFAULT 1,
    UNIQUE (SubID, StudentID),
    FOREIGN KEY (SubID) REFERENCES Subject (SubID),
    FOREIGN KEY (StudentID) REFERENCES Student (StudentID)
);

-- Bước 2: Thêm dữ liệu vào bảng Class
INSERT INTO Class VALUES (1, 'A1', '2008-12-20', 1);
INSERT INTO Class VALUES (2, 'A2', '2008-12-22', 1);
INSERT INTO Class VALUES (3, 'B3', CURRENT_DATE, 0);

-- Bước 3: Thêm dữ liệu vào bảng Student
INSERT INTO Student (StudentName, Address, Phone, Status, ClassId) 
VALUES ('Hung', 'Ha Noi', '0912113113', 1, 1);

INSERT INTO Student (StudentName, Address, Status, ClassId) 
VALUES ('Hoa', 'Hai phong', 1, 1);

INSERT INTO Student (StudentName, Address, Phone, Status, ClassId) 
VALUES ('Manh', 'HCM', '0123123123', 0, 2);

-- Bước 4: Thêm dữ liệu vào bảng Subject
INSERT INTO Subject 
VALUES (1, 'CF', 5, 1), 
       (2, 'C', 6, 1), 
       (3, 'HDJ', 5, 1), 
       (4, 'RDBMS', 10, 1);

-- Bước 5: Thêm dữ liệu vào bảng Mark
INSERT INTO Mark (SubId, StudentId, Mark, ExamTimes) 
VALUES (1, 1, 8, 1), 
       (1, 2, 10, 2), 
       (2, 1, 12, 1);

-- ==============================================================
-- BÀI THỰC HÀNH: TRUY VẤN DỮ LIỆU VỚI CSDL QUẢN LÝ SINH VIÊN
-- ==============================================================

-- Bước 1: Sử dụng cơ sở dữ liệu
USE QuanLySinhVien;

-- Bước 2: Hiển thị danh sách tất cả các học viên
SELECT * FROM Student;

-- Bước 3: Hiển thị danh sách các học viên đang theo học
SELECT * FROM Student WHERE Status = true;

-- Bước 4: Hiển thị danh sách các môn học có thời gian học nhỏ hơn 10 giờ
SELECT * FROM Subject WHERE Credit < 10;

-- Bước 5: Hiển thị danh sách học viên lớp A1
SELECT S.StudentId, S.StudentName, C.ClassName FROM Student S join Class C on S.ClassId = C.ClassID;
SELECT S.StudentId, S.StudentName, C.ClassName FROM Student S join Class C on S.ClassId = C.ClassID WHERE C.ClassName = 'A1';

-- Bước 6: Hiển thị điểm môn CF của các học viên
SELECT S.StudentId, S.StudentName, Sub.SubName, M.Mark FROM Student S join Mark M on S.StudentId = M.StudentId join Subject Sub on M.SubId = Sub.SubId;
SELECT S.StudentId, S.StudentName, Sub.SubName, M.Mark FROM Student S join Mark M on S.StudentId = M.StudentId join Subject Sub on M.SubId = Sub.SubId WHERE Sub.SubName = 'CF';

-- ==============================================================
-- BÀI TẬP: LUYỆN TẬP CÁC CÂU LỆNH TRUY VẤN TRONG MYSQL
-- ==============================================================

-- 1. Hiển thị tất cả các sinh viên có tên bắt đầu bằng ký tự 'h'
SELECT * FROM Student 
WHERE StudentName LIKE 'h%';

-- 2. Hiển thị các thông tin lớp học có thời gian bắt đầu vào tháng 12
SELECT * FROM Class 
WHERE MONTH(StartDate) = 12;

-- 3. Hiển thị tất cả các thông tin môn học có credit trong khoảng từ 3-5
SELECT * FROM Subject 
WHERE Credit BETWEEN 3 AND 5;

-- 4. Thay đổi mã lớp (ClassID) của sinh viên có tên 'Hung' là 2
SET SQL_SAFE_UPDATES = 0;
UPDATE Student 
SET ClassID = 2 
WHERE StudentName = 'Hung';
SET SQL_SAFE_UPDATES = 1;

-- 5. Hiển thị các thông tin: StudentName, SubName, Mark.
-- Dữ liệu sắp xếp theo điểm thi (Mark) giảm dần, nếu trùng thì sắp theo tên (StudentName) tăng dần.
SELECT S.StudentName, Sub.SubName, M.Mark
FROM Student S
JOIN Mark M ON S.StudentID = M.StudentID
JOIN Subject Sub ON M.SubID = Sub.SubID
ORDER BY M.Mark DESC, S.StudentName ASC;


