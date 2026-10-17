package com.codegym;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// Định tuyến URL nhận request từ thuộc tính action="login" của Form
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    // Sử dụng doPost để bắt dữ liệu từ form có method="POST"
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        // 1. Lấy dữ liệu người dùng nhập từ Form (thông qua thuộc tính 'name' của thẻ input)
        String user = request.getParameter("username");
        String pass = request.getParameter("password");

        try (PrintWriter out = response.getWriter()) {
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head><title>Login Result</title></head>");
            out.println("<body style='font-family: Arial, sans-serif; text-align: center; margin-top: 100px;'>");

            // 2. Kiểm tra điều kiện logic (admin / admin)
            if ("admin".equals(user) && "admin".equals(pass)) {
                out.println("<h1 style='color: green;'>Welcome admin to website</h1>");
            } else {
                out.println("<h1 style='color: red;'>Login Error</h1>");
            }

            out.println("<br><a href='index.jsp'>Go back</a>");
            out.println("</body>");
            out.println("</html>");
        }
    }
}
