package com.codegym.dao;

import com.codegym.model.Product;
import java.sql.SQLException;
import java.util.List;

public interface ProductDAO {
    List<Product> selectAllProducts();
    Product selectProduct(int id);
    void insertProduct(Product product) throws SQLException;
    boolean updateProduct(Product product) throws SQLException;
    boolean deleteProduct(int id) throws SQLException;
    List<Product> searchByName(String keyword);
}
