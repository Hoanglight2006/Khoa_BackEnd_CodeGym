<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.codegym.model.Product" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh Sách Sản Phẩm - Product Management</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <header class="app-header">
        <div class="header-inner">
            <a href="${pageContext.request.contextPath}/products" class="brand">
                <div class="brand-icon">&#128230;</div>
                <div>
                    <div class="brand-title">Product Manager</div>
                    <div class="brand-subtitle">Hệ thống quản lý sản phẩm cơ bản</div>
                </div>
            </a>
            <div>
                <a href="${pageContext.request.contextPath}/products?action=new" class="btn btn-primary">
                    + Thêm Sản Phẩm Mới
                </a>
            </div>
        </div>
    </header>

    <main class="container">
        <!-- Thông báo thao tác -->
        <%
            String msg = request.getParameter("msg");
            if ("added".equals(msg)) {
        %>
            <div class="alert alert-success">&#10004; Thêm sản phẩm mới thành công!</div>
        <%
            } else if ("updated".equals(msg)) {
        %>
            <div class="alert alert-success">&#10004; Cập nhật thông tin sản phẩm thành công!</div>
        <%
            } else if ("deleted".equals(msg)) {
        %>
            <div class="alert alert-success">&#10004; Đã xóa sản phẩm khỏi hệ thống!</div>
        <%
            }
        %>

        <!-- Toolbar tìm kiếm -->
        <div class="toolbar">
            <form action="${pageContext.request.contextPath}/products" method="get" class="search-box">
                <%
                    String keyword = (String) request.getAttribute("keyword");
                    if (keyword == null) keyword = "";
                %>
                <input type="text" name="keyword" value="<%= keyword %>" placeholder="Tìm kiếm theo tên sản phẩm..." class="search-input">
                <button type="submit" class="btn btn-secondary">Tìm</button>
                <% if (!keyword.isEmpty()) { %>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-secondary" title="Đặt lại">&times;</a>
                <% } %>
            </form>
        </div>

        <!-- Bảng danh sách sản phẩm -->
        <div class="card">
            <div class="table-responsive">
                <table class="product-table">
                    <thead>
                        <tr>
                            <th class="col-id">ID</th>
                            <th>Tên Sản Phẩm</th>
                            <th>Giá</th>
                            <th>Số Lượng</th>
                            <th class="col-actions">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Product> products = (List<Product>) request.getAttribute("products");
                            if (products != null && !products.isEmpty()) {
                                for (Product p : products) {
                        %>
                        <tr>
                            <td class="col-id"><%= p.getId() %></td>
                            <td class="col-name"><%= p.getName() %></td>
                            <td class="col-price"><%= p.getFormattedPrice() %></td>
                            <td class="col-quantity">
                                <span class="quantity-badge"><%= p.getQuantity() %> cái</span>
                            </td>
                            <td class="col-actions">
                                <div class="action-btns">
                                    <a href="${pageContext.request.contextPath}/products?action=edit&id=<%= p.getId() %>" class="btn-action-edit">
                                        Sửa
                                    </a>
                                    <a href="${pageContext.request.contextPath}/products?action=delete&id=<%= p.getId() %>" 
                                       class="btn-action-delete"
                                       onclick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm \'<%= p.getName() %>\' (ID: <%= p.getId() %>) không?');">
                                        Xóa
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="5">
                                <div class="empty-box">
                                    <div class="empty-icon">&#128194;</div>
                                    <h3>Chưa có sản phẩm nào</h3>
                                    <p>Bấm vào <strong>+ Thêm Sản Phẩm Mới</strong> để tạo sản phẩm đầu tiên.</p>
                                </div>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

</body>
</html>
