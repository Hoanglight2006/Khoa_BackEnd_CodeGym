<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.codegym.model.Note" %>
<%@ page import="com.codegym.model.NoteType" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>iNotes - Quản lý Ghi Chú Cá Nhân</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <header class="app-header">
        <div class="header-content">
            <a href="${pageContext.request.contextPath}/notes" class="logo-area">
                <div class="logo-icon">&#9998;</div>
                <div class="logo-text">i<span>Notes</span></div>
            </a>

            <!-- Runtime Storage Switcher (Strategy Pattern) -->
            <div class="storage-control">
                <span>Lưu trữ:</span>
                <%
                    String currentStorage = (String) request.getAttribute("currentStorage");
                    boolean isDb = currentStorage != null && currentStorage.contains("MySQL");
                %>
                <span class="storage-badge <%= isDb ? "db" : "file" %>">
                    <%= isDb ? "&#128451; CSDL MySQL" : "&#128196; File TXT" %>
                </span>
                <a href="${pageContext.request.contextPath}/notes?action=switch-storage&mode=<%= isDb ? "file" : "db" %>" class="storage-switch-btn" title="Bấm để đổi tầng lưu trữ tức thì (Strategy Pattern)">
                    Chuyển sang <%= isDb ? "File TXT" : "MySQL" %> &rarr;
                </a>
            </div>
        </div>
    </header>

    <main class="container">
        <!-- Thông báo Toast / Feedback -->
        <%
            String msg = request.getParameter("msg");
            if ("created".equals(msg)) {
        %>
            <div class="alert alert-success">&#10004; Ghi chú mới đã được thêm thành công!</div>
        <%
            } else if ("updated".equals(msg)) {
        %>
            <div class="alert alert-success">&#10004; Cập nhật ghi chú thành công!</div>
        <%
            } else if ("deleted".equals(msg)) {
        %>
            <div class="alert alert-success">&#10004; Đã xóa ghi chú thành công!</div>
        <%
            } else if ("storage_switched".equals(msg)) {
        %>
            <div class="alert alert-warning">&#9889; Đã chuyển đổi chiến lược lưu trữ sang: <strong><%= currentStorage %></strong></div>
        <%
            }
        %>

        <!-- Action Bar: Tìm kiếm + Thêm Mới (Bước 5) -->
        <div class="action-bar">
            <form action="${pageContext.request.contextPath}/notes" method="get" class="search-form">
                <div class="search-input-wrap">
                    <span class="search-icon">&#128269;</span>
                    <%
                        String keyword = (String) request.getAttribute("keyword");
                        if (keyword == null) keyword = "";
                    %>
                    <input type="text" name="keyword" value="<%= keyword %>" placeholder="Tìm theo tiêu đề hoặc nội dung..." class="search-input">
                </div>
                <button type="submit" class="btn btn-secondary">Tìm kiếm</button>
                <% if (!keyword.isEmpty()) { %>
                    <a href="${pageContext.request.contextPath}/notes" class="btn btn-secondary" title="Xóa tìm kiếm">&times;</a>
                <% } %>
            </form>

            <a href="${pageContext.request.contextPath}/notes?action=new" class="btn btn-primary">
                + Thêm Mới
            </a>
        </div>

        <!-- Bảng Danh Sách Ghi Chú (iNotes Dashboard) -->
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">Danh Sách Ghi Chú</h2>
            </div>

            <div class="table-responsive">
                <table class="notes-table">
                    <thead>
                        <tr>
                            <th style="width: 60px;">#</th>
                            <th>Tiêu đề</th>
                            <th style="width: 140px;">Phân loại</th>
                            <th style="width: 180px; text-align: center;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Note> notes = (List<Note>) request.getAttribute("notes");
                            if (notes != null && !notes.isEmpty()) {
                                int index = 1;
                                for (Note note : notes) {
                                    String badgeClass = "badge-other";
                                    String typeName = note.getTypeName();
                                    if (typeName == null || typeName.isEmpty()) {
                                        typeName = "Chung";
                                    }
                                    if ("Cá nhân".equalsIgnoreCase(typeName)) {
                                        badgeClass = "badge-personal";
                                    } else if ("Công việc".equalsIgnoreCase(typeName)) {
                                        badgeClass = "badge-work";
                                    } else if ("Học tập".equalsIgnoreCase(typeName)) {
                                        badgeClass = "badge-study";
                                    }
                        %>
                        <tr>
                            <td class="note-id"><%= index++ %></td>
                            <td class="note-title-cell">
                                <a href="${pageContext.request.contextPath}/notes?action=view&id=<%= note.getId() %>">
                                    <%= note.getTitle() %>
                                </a>
                                <div class="note-excerpt">
                                    <%= note.getContent() != null ? note.getContent() : "" %>
                                </div>
                            </td>
                            <td>
                                <span class="badge <%= badgeClass %>"><%= typeName %></span>
                            </td>
                            <td style="text-align: center;">
                                <div class="action-links" style="justify-content: center;">
                                    <a href="${pageContext.request.contextPath}/notes?action=view&id=<%= note.getId() %>" class="action-link view">Xem</a>
                                    <span class="divider">|</span>
                                    <a href="${pageContext.request.contextPath}/notes?action=edit&id=<%= note.getId() %>" class="action-link edit">Sửa</a>
                                    <span class="divider">|</span>
                                    <a href="${pageContext.request.contextPath}/notes?action=delete&id=<%= note.getId() %>" class="action-link delete" onclick="return confirm('Bạn có chắc chắn muốn xóa ghi chú này không?');">Xóa</a>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="4">
                                <div class="empty-state">
                                    <div class="empty-icon">&#128221;</div>
                                    <h3>Chưa có ghi chú nào</h3>
                                    <p>Hãy bấm vào <strong>+ Thêm Mới</strong> để tạo ghi chú đầu tiên của bạn.</p>
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
