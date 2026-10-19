<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.codegym.model.Note" %>
<%@ page import="com.codegym.model.NoteType" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%
        Note note = (Note) request.getAttribute("note");
        boolean isEdit = (note != null);
        String formTitle = isEdit ? "Cập Nhật Ghi Chú" : "Thêm Mới Ghi Chú";
    %>
    <title><%= formTitle %> - iNotes</title>
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
        <div class="form-card">
            <h1 class="form-title">
                <%= isEdit ? "&#9997; Cập Nhật Ghi Chú" : "&#10010; Thêm Mới Ghi Chú" %>
            </h1>

            <form action="${pageContext.request.contextPath}/notes" method="post">
                <input type="hidden" name="action" value="<%= isEdit ? "update" : "create" %>">
                <% if (isEdit) { %>
                    <input type="hidden" name="id" value="<%= note.getId() %>">
                <% } %>

                <!-- 1. Tiêu đề: Ô nhập văn bản - text input -->
                <div class="form-group">
                    <label for="title" class="form-label">Tiêu đề *</label>
                    <input type="text"
                           id="title"
                           name="title"
                           class="form-control"
                           placeholder="Nhập tiêu đề ghi chú..."
                           value="<%= isEdit ? note.getTitle() : "" %>"
                           required>
                </div>

                <!-- 2. Phân loại: Hộp chọn danh mục - Select dropdown -->
                <div class="form-group">
                    <label for="typeId" class="form-label">Phân loại *</label>
                    <select id="typeId" name="typeId" class="form-control" required>
                        <%
                            List<NoteType> types = (List<NoteType>) request.getAttribute("types");
                            int selectedTypeId = (isEdit ? note.getTypeId() : 1);
                            if (types != null) {
                                for (NoteType t : types) {
                                    boolean selected = (t.getId() == selectedTypeId);
                        %>
                            <option value="<%= t.getId() %>" <%= selected ? "selected" : "" %>>
                                <%= t.getName() %>
                            </option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>

                <!-- 3. Nội dung: Khung soạn thảo nhiều dòng - Textarea -->
                <div class="form-group">
                    <label for="content" class="form-label">Nội dung chi tiết</label>
                    <textarea id="content"
                              name="content"
                              class="form-control"
                              placeholder="Nhập nội dung chi tiết của ghi chú tại đây..."><%= isEdit && note.getContent() != null ? note.getContent() : "" %></textarea>
                </div>

                <!-- Nút thao tác: Lưu Ghi Chú & Hủy bỏ -->
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        <%= isEdit ? "Cập Nhật Ghi Chú" : "Lưu Ghi Chú" %>
                    </button>
                    <a href="${pageContext.request.contextPath}/notes" class="btn btn-secondary">
                        Hủy bỏ
                    </a>
                </div>
            </form>
        </div>
    </main>

</body>
</html>
