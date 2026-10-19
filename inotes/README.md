# Ứng Dụng Quản Lý Ghi Chú iNotes (Strategy Pattern)

Dự án ứng dụng web **iNotes** xây dựng theo mô hình MVC (Model - View - Controller) sử dụng **Jakarta Servlet / JSP**, tích hợp mẫu thiết kế **Strategy Pattern** giúp chuyển đổi linh hoạt tầng lưu trữ dữ liệu giữa **Cơ sở dữ liệu (MySQL)** và **Tập tin (File txt/csv)** lúc runtime mà không làm thay đổi logic giao diện.

---

## 1. Cấu Trúc Dự Án

```
inotes/
├── pom.xml                                   # Cấu hình Maven (Jakarta EE 10, MySQL Driver, JSTL)
├── inotes_db.sql                             # Kịch bản khởi tạo CSDL MySQL và dữ liệu mẫu
├── notes_data.txt                            # File lưu trữ dữ liệu text (phân tách id|title|content|typeId)
├── src/main/
│   ├── java/com/codegym/
│   │   ├── model/
│   │   │   ├── Note.java                     # Model Note với phương thức save(), delete(id)
│   │   │   └── NoteType.java                 # Model thể loại (Cá nhân, Công việc, Học tập)
│   │   ├── strategy/
│   │   │   ├── NoteStrategy.java             # Interface chuẩn chung cho các chiến lược lưu trữ
│   │   │   ├── NoteDBStrategy.java           # Chiến lược lưu trữ trên MySQL qua JDBC
│   │   │   └── NoteFileStrategy.java         # Chiến lược lưu trữ trên tệp tin text/csv
│   │   ├── service/
│   │   │   └── NoteManagement.java           # Lớp điều khiển chứa NoteStrategy (Runtime Pluggable Storage)
│   │   ├── controller/
│   │   │   └── NoteServlet.java              # Controller xử lý routing, thêm, sửa, xóa, tìm kiếm
│   │   └── util/
│   │       └── DBConnection.java             # Quản lý kết nối JDBC MySQL
│   ├── resources/
│   │   └── db.properties                     # Cấu hình kết nối MySQL (url, user, password)
│   └── webapp/
│       ├── WEB-INF/web.xml                   # Cấu hình Web Application
│       ├── css/style.css                     # Giao diện CSS hiện đại (Responsive, Badge phân loại)
│       ├── views/
│       │   ├── note-list.jsp                 # Giao diện Danh sách (Dashboard) & Tìm kiếm
│       │   ├── note-form.jsp                 # Giao diện Thêm mới & Cập nhật ghi chú
│       │   └── note-view.jsp                 # Giao diện Xem chi tiết ghi chú
│       └── index.jsp                         # Trang đích chuyển hướng tự động sang /notes
```

---

## 2. Hướng Dẫn Cài Đặt và Khởi Chạy

### Bước 1: Khởi tạo Cơ sở dữ liệu MySQL
1. Mở MySQL Workbench hoặc chạy lệnh từ cửa sổ dòng lệnh:
   ```bash
   mysql -u root -p < inotes_db.sql
   ```
2. Cập nhật thông tin tài khoản MySQL (nếu khác mật khẩu mặc định `root`) trong file:
   `src/main/resources/db.properties`:
   ```properties
   db.url=jdbc:mysql://localhost:3306/inotes_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8
   db.user=root
   db.password=mật_khẩu_của_bạn
   ```

### Bước 2: Chạy ứng dụng trên Tomcat 10+
1. Mở dự án trong IDE (IntelliJ IDEA / Eclipse / VS Code).
2. Thêm máy chủ Apache Tomcat (phiên bản 10.x hoặc 10.1.x hỗ trợ Jakarta EE).
3. Triển khai war hoặc thư mục `webapp` lên Tomcat.
4. Truy cập trình duyệt tại: `http://localhost:8080/inotes`

---

## 3. Cách Thức Hoạt Động Của Strategy Pattern

- **Interface `NoteStrategy`**: Định nghĩa hợp đồng chung gồm:
  - `save(Note note)`: Thêm mới hoặc cập nhật ghi chú.
  - `delete(int id)`: Xóa ghi chú.
  - `findAll()`: Lấy danh sách toàn bộ ghi chú.
  - `findById(int id)`: Xem chi tiết theo mã ID.
  - `search(String keyword)`: Tìm kiếm theo tiêu đề hoặc nội dung.
  - `findAllTypes()`: Lấy danh mục thể loại (Cá nhân, Công việc, Học tập).

- **Chuyển đổi lúc Runtime**:
  - Tại giao diện thanh công cụ trên cùng, người dùng bấm vào nút chuyển đổi để đổi qua lại giữa **CSDL MySQL** và **File TXT**.
  - Lớp `NoteManagement` gọi `setStrategy(NoteStrategy strategy)` để thay đổi đối tượng chiến lược mà không cần khởi động lại ứng dụng.
