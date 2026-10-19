<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.codegym.model.Note" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%
        Note note = (Note) request.getAttribute("note");
    %>
    <title><%= note != null ? note.getTitle() : "Chi tiết" %> - iNotes</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <header class="app-header">
        <div class="header-content">
            <a href="${pageContext.request.contextPath}/notes" class="logo-area">
                <div class="logo-icon">&#9998;</div>
                <div class="logo-text">i<span>Notes</span></div>
            </a>
            <div class="storage-control">
                <span>Tầng lưu trữ:</span>
                <%
                    String currentStorage = (String) request.getAttribute("currentStorage");
                    boolean isDb = currentStorage != null && currentStorage.contains("MySQL");
                %>
                <span class="storage-badge <%= isDb ? "db" : "file" %>">
                    <%= isDb ? "&#128451; CSDL MySQL" : "&#128196; File TXT" %>
                </span>
            </div>
        </div>
    </header>

    <main class="container">
        <% if (note != null) { 
            String badgeClass = "badge-other";
            String typeName = note.getTypeName();
            if ("Cá nhân".equalsIgnoreCase(typeName)) {
                badgeClass = "badge-personal";
            } else if ("Công việc".equalsIgnoreCase(typeName)) {
                badgeClass = "badge-work";
            } else if ("Học tập".equalsIgnoreCase(typeName)) {
                badgeClass = "badge-study";
            }
        %>
            <div class="view-card">
                <div class="view-meta">
                    <span class="badge <%= badgeClass %>"><%= typeName != null ? typeName : "Chung" %></span>
                    <span style="color: var(--text-muted); font-size: 13px;">Mã số: #<%= note.getId() %></span>
                </div>

                <h1 class="view-title"><%= note.getTitle() %></h1>

                <div class="view-content"><%= note.getContent() != null ? note.getContent() : "Không có nội dung." %></div>

                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/notes?action=edit&id=<%= note.getId() %>" class="btn btn-primary">
                        Sửa Ghi Chú
                    </a>
                    <a href="${pageContext.request.contextPath}/notes?action=delete&id=<%= note.getId() %>" class="btn btn-secondary" onclick="return confirm('Bạn có chắc chắn muốn xóa ghi chú này?');" style="color: var(--danger);">
                        Xóa Ghi Chú
                    </a>
                    <a href="${pageContext.request.contextPath}/notes" class="btn btn-secondary">
                        &larr; Quay lại danh sách
                    </a>
                </div>
            </div>
        <% } else { %>
            <div class="alert alert-warning">
                Không tìm thấy ghi chú yêu cầu. <a href="${pageContext.request.contextPath}/notes">Quay lại danh sách</a>
            </div>
        <% } %>
    </main>

</body>
</html>
