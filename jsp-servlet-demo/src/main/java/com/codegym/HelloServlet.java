package com.codegym;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// Khai báo định tuyến URL: Khi gõ "/hello", trình duyệt sẽ kích hoạt Servlet này
@WebServlet(name = "HelloServlet", urlPatterns = {"/hello"})
public class HelloServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Cấu hình phản hồi hiển thị HTML và hỗ trợ hiển thị Tiếng Việt có dấu
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head><title>Hello Servlet</title></head>");
            out.println("<body style='font-family: Arial, sans-serif; text-align: center; margin-top: 100px;'>");
            out.println("<h1 style='color: #1b2a7a;'>Chào mừng bạn đến với Servlet đầu tiên!</h1>");
            out.println("<p style='color: #f15a24; font-size: 18px;'>Ứng dụng đang chạy mượt mà trên Antigravity IDE 2026</p>");
            out.println("<a href='index.jsp'>Quay lại trang chủ JSP</a>");
            out.println("</body>");
            out.println("</html>");
        }
    }
}
