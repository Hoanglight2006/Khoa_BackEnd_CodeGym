<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.codegym.model.Product" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%
        Product product = (Product) request.getAttribute("product");
        boolean isEdit = (product != null);
        String pageTitle = isEdit ? "Sửa Thông Tin Sản Phẩm" : "Thêm Sản Phẩm Mới";
    %>
    <title><%= pageTitle %> - Product Management</title>
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
        </div>
    </header>

    <main class="container">
        <div class="form-card">
            <div class="form-header">
                <h1 class="form-title"><%= pageTitle %></h1>
            </div>

            <%
                String error = (String) request.getAttribute("error");
                if (error != null) {
            %>
                <div class="alert alert-danger"><%= error %></div>
            <%
                }
            %>

            <form action="${pageContext.request.contextPath}/products" method="post">
                <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
                <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= product.getId() %>">
                <% } %>

                <!-- Tên sản phẩm -->
                <div class="form-group">
                    <label for="name" class="form-label">Tên sản phẩm *</label>
                    <input type="text"
                           id="name"
                           name="name"
                           class="form-control"
                           placeholder="Nhập tên sản phẩm..."
                           value="<%= isEdit ? product.getName() : "" %>"
                           required>
                </div>

                <!-- Giá -->
                <div class="form-group">
                    <label for="price" class="form-label">Giá sản phẩm (VNĐ) *</label>
                    <input type="number"
                           id="price"
                           name="price"
                           class="form-control"
                           placeholder="Nhập giá (ví dụ: 15000000)"
                           step="1000"
                           min="0"
                           value="<%= isEdit ? String.format("%.0f", product.getPrice()) : "" %>"
                           required>
                </div>

                <!-- Số lượng -->
                <div class="form-group">
                    <label for="quantity" class="form-label">Số lượng *</label>
                    <input type="number"
                           id="quantity"
                           name="quantity"
                           class="form-control"
                           placeholder="Nhập số lượng tồn kho..."
                           min="0"
                           value="<%= isEdit ? product.getQuantity() : "" %>"
                           required>
                </div>

                <!-- Thao tác form -->
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        <%= isEdit ? "Cập Nhật Sản Phẩm" : "Thêm Sản Phẩm" %>
                    </button>
                    <a href="${pageContext.request.contextPath}/products" class="btn btn-secondary">
                        Hủy bỏ
                    </a>
                </div>
            </form>
        </div>
    </main>

</body>
</html>
