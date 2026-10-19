package com.codegym.controller;

import com.codegym.dao.ProductDAO;
import com.codegym.dao.ProductDAOImpl;
import com.codegym.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "ProductServlet", urlPatterns = {"/products", ""})
public class ProductServlet extends HttpServlet {
    private ProductDAO productDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        productDAO = new ProductDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "new":
                showNewForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteProduct(request, response);
                break;
            case "list":
            default:
                listProducts(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "insert":
                insertProduct(request, response);
                break;
            case "update":
                updateProduct(request, response);
                break;
            default:
                listProducts(request, response);
                break;
        }
    }

    private void listProducts(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        List<Product> products;
        if (keyword != null && !keyword.trim().isEmpty()) {
            products = productDAO.searchByName(keyword.trim());
        } else {
            products = productDAO.selectAllProducts();
        }

        request.setAttribute("products", products);
        request.setAttribute("keyword", keyword);
        request.getRequestDispatcher("/views/product-list.jsp").forward(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/views/product-form.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Product existingProduct = productDAO.selectProduct(id);
            if (existingProduct != null) {
                request.setAttribute("product", existingProduct);
                request.getRequestDispatcher("/views/product-form.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/products?error=not_found");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/products?error=invalid_id");
        }
    }

    private void insertProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String name = request.getParameter("name");
        String priceStr = request.getParameter("price");
        String quantityStr = request.getParameter("quantity");

        try {
            double price = Double.parseDouble(priceStr);
            int quantity = Integer.parseInt(quantityStr);

            Product newProduct = new Product(name, price, quantity);
            productDAO.insertProduct(newProduct);
            response.sendRedirect(request.getContextPath() + "/products?msg=added");
        } catch (NumberFormatException | SQLException e) {
            request.setAttribute("error", "Dữ liệu nhập không hợp lệ hoặc lỗi cơ sở dữ liệu: " + e.getMessage());
            request.getRequestDispatcher("/views/product-form.jsp").forward(request, response);
        }
    }

    private void updateProduct(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            double price = Double.parseDouble(request.getParameter("price"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            Product product = new Product(id, name, price, quantity);
            productDAO.updateProduct(product);
            response.sendRedirect(request.getContextPath() + "/products?msg=updated");
        } catch (NumberFormatException | SQLException e) {
            request.setAttribute("error", "Không thể cập nhật sản phẩm: " + e.getMessage());
            showEditForm(request, response);
        }
    }

    private void deleteProduct(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            productDAO.deleteProduct(id);
            response.sendRedirect(request.getContextPath() + "/products?msg=deleted");
        } catch (NumberFormatException | SQLException e) {
            response.sendRedirect(request.getContextPath() + "/products?error=delete_failed");
        }
    }
}
