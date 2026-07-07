//package com.alex.utils;
//
//import java.sql.Connection;
//import java.sql.DriverManager;
//import java.sql.SQLException;
//
//public class DBUtil {
//    // 💡 架构师优化：加上了 characterEncoding 和 serverTimezone 防止中文乱码和时间错乱
//    private static final String URL = "jdbc:mysql://localhost:3306/2026_aiworkflow?useSSL=false&characterEncoding=utf8&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true";    private static final String USER = "root";
//    private static final String PASSWORD = "hahaha233";
//
//    // 【核心修复】：静态代码块，强制加载 MySQL 8.x 驱动
//    static {
//        try {
//            Class.forName("com.mysql.cj.jdbc.Driver");
//            System.out.println("✅ MySQL 驱动加载成功！");
//        } catch (ClassNotFoundException e) {
//            System.err.println("❌ 致命错误：找不到 MySQL 驱动包！请确认 jar 包已放入 WEB-INF/lib！");
//            e.printStackTrace();
//        }
//    }
//
//    public static Connection getConnection() throws SQLException {
//        return DriverManager.getConnection(URL, USER, PASSWORD);
//    }
//
//    public static void close(Connection conn) {
//        try {
//            if (conn != null) conn.close();
//        } catch (SQLException e) {
//            e.printStackTrace();
//        }
//    }
//}