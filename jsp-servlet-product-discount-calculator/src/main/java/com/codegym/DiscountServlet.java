package com.codegym;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "DiscountServlet", urlPatterns = {"/display-discount"})
public class DiscountServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String discountStr = request.getParameter("discount");

        try (PrintWriter out = response.getWriter()) {
            try {
                double listPrice = Double.parseDouble(priceStr);
                double discountPercent = Double.parseDouble(discountStr);

                // Tính toán lượng chiết khấu và giá sau chiết khấu
                double discountAmount = listPrice * discountPercent * 0.01;
                double discountPrice = listPrice - discountAmount;

                out.println("<!DOCTYPE html>");
                out.println("<html>");
                out.println("<head>");
                out.println("<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>");
                out.println("<title>Discount Calculation Result</title>");
                out.println("<style>");
                out.println("body { font-family: Arial, sans-serif; display: flex; justify-content: center; margin-top: 80px; background-color: #f8fafc; }");
                out.println(".result-card { background: white; padding: 35px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); width: 420px; }");
                out.println("h2 { color: #1b2a7a; text-align: center; margin-bottom: 25px; }");
                out.println(".item { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #f1f5f9; }");
                out.println(".label { font-weight: bold; color: #475569; }");
                out.println(".value { color: #0f172a; }");
                out.println(".highlight { color: #16a34a; font-weight: bold; font-size: 18px; }");
                out.println(".btn { display: block; text-align: center; margin-top: 25px; padding: 12px; background-color: #1b2a7a; color: white; text-decoration: none; border-radius: 4px; font-weight: bold; }");
                out.println(".btn:hover { background-color: #121c54; }");
                out.println("</style>");
                out.println("</head>");
                out.println("<body>");
                out.println("<div class='result-card'>");
                out.println("<h2>Product Discount Calculator</h2>");
                out.println("<div class='item'><span class='label'>Product Description:</span><span class='value'>" + (description != null ? description : "") + "</span></div>");
                out.println("<div class='item'><span class='label'>List Price:</span><span class='value'>$" + String.format("%.2f", listPrice) + "</span></div>");
                out.println("<div class='item'><span class='label'>Discount Percent:</span><span class='value'>" + discountPercent + "%</span></div>");
                out.println("<div class='item'><span class='label'>Discount Amount:</span><span class='value'>$" + String.format("%.2f", discountAmount) + "</span></div>");
                out.println("<div class='item'><span class='label'>Discount Price:</span><span class='value highlight'>$" + String.format("%.2f", discountPrice) + "</span></div>");
                out.println("<a href='index.jsp' class='btn'>Calculate Again</a>");
                out.println("</div>");
                out.println("</body>");
                out.println("</html>");
            } catch (NumberFormatException e) {
                out.println("<!DOCTYPE html>");
                out.println("<html><body>");
                out.println("<h2 style='color: red; text-align: center; margin-top: 100px;'>Lỗi: Vui lòng nhập số hợp lệ cho giá và chiết khấu!</h2>");
                out.println("<div style='text-align: center;'><a href='index.jsp'>Quay lại</a></div>");
                out.println("</body></html>");
            }
        }
    }
}
