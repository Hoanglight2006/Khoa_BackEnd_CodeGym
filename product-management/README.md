# Bài Kiểm Tra Cuối Module: Quản Lý Sản Phẩm (Product Management)

Dự án ứng dụng web quản lý sản phẩm cơ bản xây dựng theo mô hình kiến trúc MVC (Model - View - Controller) sử dụng **JSP & Servlet** (Jakarta EE) và cơ sở dữ liệu **MySQL** qua JDBC.

---

## 1. Cấu Trúc Dự Án

```
product-management/
├── pom.xml                                   # Cấu hình Maven (Jakarta Servlet 6.0, JSP, JSTL, MySQL)
├── product_db.sql                            # Kịch bản tạo database product_management_db và dữ liệu mẫu
├── src/main/
│   ├── java/com/codegym/
│   │   ├── model/
│   │   │   └── Product.java                  # Model đối tượng Product (id, name, price, quantity)
│   │   ├── dao/
│   │   │   ├── ProductDAO.java               # Interface Data Access Object
│   │   │   └── ProductDAOImpl.java           # Thực thi JDBC CRUD và tìm kiếm sản phẩm
│   │   ├── controller/
│   │   │   └── ProductServlet.java           # Servlet điều hướng hiển thị, thêm, sửa, xóa
│   │   └── util/
│   │       └── DBConnection.java             # Quản lý kết nối JDBC MySQL
│   ├── resources/
│   │   └── db.properties                     # Cấu hình kết nối cơ sở dữ liệu
│   └── webapp/
│       ├── WEB-INF/web.xml                   # Cấu hình triển khai web
│       ├── css/style.css                     # Giao diện hiện đại, responsive
│       ├── views/
│       │   ├── product-list.jsp              # Bảng danh sách sản phẩm, thao tác Sửa, Xóa, Tìm kiếm
│       │   └── product-form.jsp              # Biểu mẫu Thêm mới và Chỉnh sửa sản phẩm
│       └── index.jsp                         # Trang điều hướng mặc định sang /products
```

---

## 2. Hướng Dẫn Cài Đặt và Khởi Chạy

### Bước 1: Khởi tạo Cơ sở dữ liệu MySQL
1. Mở MySQL Workbench hoặc chạy lệnh từ Command Line:
   ```bash
   mysql -u root -p < product_db.sql
   ```
2. Cập nhật mật khẩu kết nối trong file `src/main/resources/db.properties` nếu mật khẩu MySQL khác `root`.

### Bước 2: Triển khai trên Apache Tomcat
1. Mở dự án trong IntelliJ IDEA / Eclipse / VS Code.
2. Cấu hình máy chủ **Apache Tomcat 10+** (hỗ trợ Jakarta EE).
3. Triển khai (Deploy) thư mục hoặc file WAR lên Tomcat.
4. Truy cập qua trình duyệt: `http://localhost:8080/product-management/`

---

## 3. Các Chức Năng Đã Triển Khai
1. **Hiển thị danh sách sản phẩm**: Hiển thị bảng gồm ID, Tên sản phẩm, Đơn giá, Số lượng, cùng các nút thao tác.
2. **Thêm sản phẩm mới**: Form nhập Tên, Giá, Số lượng kèm kiểm tra hợp lệ dữ liệu.
3. **Sửa thông tin sản phẩm**: Chọn sản phẩm, mở form nạp sẵn dữ liệu cũ để cập nhật.
4. **Xóa sản phẩm**: Có hộp thoại xác nhận (JavaScript confirm popup) trước khi thực hiện xóa.
5. **Tìm kiếm sản phẩm**: Tìm kiếm nhanh theo tên sản phẩm.
