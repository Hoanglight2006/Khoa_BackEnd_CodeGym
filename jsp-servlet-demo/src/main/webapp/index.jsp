<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>CodeGym JSP Demo</title>
</head>
<body style="font-family: 'Arial', sans-serif; text-align: center; margin-top: 100px; background-color: #f8fafc;">
    <h2 style="color: #1b2a7a; font-size: 36px;">Chào mừng tới lớp học Java Web!</h2>
    <p style="font-size: 18px;">Đây là trang JSP động được biên dịch trực tiếp từ Tomcat Server.</p>
    <%-- Nhúng mã Java động xử lý thời gian qua JSP Scriptlet --%>
    <% java.util.Date date = new java.util.Date(); %>
    <p style="color: #64748b;">Thời gian hệ thống hiện tại: <strong style="color: #f15a24;"><%= date %></strong></p>
    <br/>
    <a href="hello" style="background-color: #1b2a7a; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px;">Đi tới HelloServlet</a>
</body>
</html>
