package com.recruitx.controller;

import com.recruitx.config.DBConnection;
import com.recruitx.model.User;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AuthEngine")
public class AuthServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== AuthServlet Called ===");

        String action = request.getParameter("action");
        System.out.println("Action = " + action);

        // ================= ONLY CANDIDATES CAN REGISTER =================
        if ("register".equals(action)) {
            String username = request.getParameter("username");
            String pass = request.getParameter("password");
            String fullName = request.getParameter("fullName");
            String role = "CANDIDATE"; // Forces role to CANDIDATE regardless of inputs

            // Step 1: Pre-check if Username/Matric ID already exists to prevent crash
            String checkSql = "SELECT COUNT(*) FROM users WHERE username = ?";
            try (Connection conn = DBConnection.getConnection(); PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {

                checkStmt.setString(1, username);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        request.setAttribute("error", "Username/Metric ID already exists. Try using your unique Matric ID or another handle.");
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                        return;
                    }
                }

                // Step 2: Username is unique, proceed with standard registration insert
                String insertSql = "INSERT INTO users (username, password, role, full_name) VALUES (?, ?, ?, ?)";
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                    insertStmt.setString(1, username);
                    insertStmt.setString(2, pass);
                    insertStmt.setString(3, role);
                    insertStmt.setString(4, fullName);
                    insertStmt.executeUpdate();

                    request.setAttribute("successMessage", "Candidate account created successfully! Please sign in.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            } catch (SQLException e) {
                request.setAttribute("error", "Database error encountered during registration: " + e.getMessage());
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
            return;
        }

        // ================= SYSTEM LOGIN ENGINE DISPATCH =================
        String userIn = request.getParameter("username");
        String passIn = request.getParameter("password");

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE username = ? AND password = ?")) {
            stmt.setString(1, userIn);
            stmt.setString(2, passIn);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User(rs.getInt("id"), rs.getString("username"), rs.getString("role"), rs.getString("full_name"));
                    HttpSession session = request.getSession(true);
                    session.setAttribute("currentUser", user);

                    if ("RECRUITER".equals(user.getRole())) {
                        response.sendRedirect("recruiter/recruiterDashboard.jsp");
                    } else {
                        response.sendRedirect("candidate/candidatePortal.jsp");
                    }
                } else {
                    request.setAttribute("error", "Invalid Credentials Provided.");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                }
            }
        } catch (SQLException e) {
            throw new ServletException("Database authentication subsystem transaction crash", e);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        response.sendRedirect("login.jsp");
    }
}
