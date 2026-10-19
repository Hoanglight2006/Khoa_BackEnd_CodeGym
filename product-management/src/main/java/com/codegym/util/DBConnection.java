package com.codegym.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnection {
    private static String url = "jdbc:mysql://localhost:3306/product_management_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&characterEncoding=UTF-8";
    private static String user = "root";
    private static String password = "root";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (InputStream input = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (input != null) {
                    Properties prop = new Properties();
                    prop.load(input);
                    if (prop.getProperty("db.url") != null) url = prop.getProperty("db.url");
                    if (prop.getProperty("db.user") != null) user = prop.getProperty("db.user");
                    if (prop.getProperty("db.password") != null) password = prop.getProperty("db.password");
                }
            } catch (Exception ignored) {
            }
        } catch (ClassNotFoundException e) {
            System.err.println("Không tìm thấy MySQL Driver: " + e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }
}
