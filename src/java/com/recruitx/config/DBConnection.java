package com.recruitx.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;

public class DBConnection {

    // Target exact schema matching your script
    private static final String URL = "jdbc:mysql://localhost:3307/recruitx_db?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true&createDatabaseIfNotExist=true";
    private static final String USER = "root";
    private static final String PASSWORD = ""; // Default XAMPP password is empty string
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Critical: MySQL JDBC Driver missing from project classpath libraries.", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);

        System.out.println("Connected Database = " + conn.getCatalog());

        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SHOW TABLES");

        System.out.println("===== TABLES =====");
        while (rs.next()) {
            System.out.println(rs.getString(1));
        }
        System.out.println("==================");

        return conn;
    }
}
