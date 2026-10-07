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

-- 1. Hiển thị danh sách tất cả các học viên
SELECT * FROM Student;

-- 2. Hiển thị danh sách các học viên đang theo học (Status = true/1)
SELECT * FROM Student 
WHERE Status = true;

-- 3. Hiển thị danh sách các môn học có thời gian học (Credit) nhỏ hơn 10
SELECT * FROM Subject 
WHERE Credit < 10;

-- 4. Hiển thị danh sách học viên lớp A1 (sử dụng JOIN giữa Student và Class)
SELECT S.StudentID, S.StudentName, C.ClassName 
FROM Student S 
JOIN Class C ON S.ClassID = C.ClassID 
WHERE C.ClassName = 'A1';

-- 5. Hiển thị điểm môn CF của các học viên (sử dụng JOIN giữa Student, Mark, Subject)
SELECT S.StudentID, S.StudentName, Sub.SubName, M.Mark 
FROM Student S 
JOIN Mark M ON S.StudentID = M.StudentID 
JOIN Subject Sub ON M.SubID = Sub.SubID 
WHERE Sub.SubName = 'CF';

