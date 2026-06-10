package com.recruitx.controller;

import com.recruitx.config.DBConnection;
import com.recruitx.model.User;
import java.io.File;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AuthEngine")
// Crucial Annotation to enable handling of file data boundaries
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AuthServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== AuthServlet Called ===");

        String action = request.getParameter("action");
        System.out.println("Action = " + action);

        // ================= CANDIDATE REGISTRATION HANDLER =================
        if ("register".equals(action)) {
            String username = request.getParameter("username");
            String pass = request.getParameter("password");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email"); 
            String role = "CANDIDATE";

            String checkSql = "SELECT COUNT(*) FROM users WHERE username = ? OR email = ?";
            try (Connection conn = DBConnection.getConnection(); PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {

                checkStmt.setString(1, username);
                checkStmt.setString(2, email);
                
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        request.setAttribute("error", "Username or Email address already exists inside our pipeline records.");
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                        return;
                    }
                }

                String insertSql = "INSERT INTO users (username, password, role, full_name, email) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                    insertStmt.setString(1, username);
                    insertStmt.setString(2, pass);
                    insertStmt.setString(3, role);
                    insertStmt.setString(4, fullName);
                    insertStmt.setString(5, email); 
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

        // ================= NEW UPDATE CANDIDATE PROFILE HANDLER =================
        if ("updateProfile".equals(action)) {
            HttpSession session = request.getSession(false);
            User user = (session != null) ? (User) session.getAttribute("currentUser") : null;
            
            if (user == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            String fullName = request.getParameter("fullName");
            
            // Extract file part content from multi-part data request boundary
            Part filePart = request.getPart("resumePdf");
            String contentDisp = filePart.getHeader("content-disposition");
            String fileName = null;
            
            for (String token : contentDisp.split(";")) {
                if (token.trim().startsWith("filename")) {
                    fileName = token.substring(token.indexOf("=") + 2, token.length() - 1);
                }
            }
            
            if (fileName != null && fileName.toLowerCase().endsWith(".pdf")) {
                String savedFileName = "Resume_" + user.getUsername() + ".pdf";
                
                // Track location folder within web deployment space on server runtime execution context
                String applicationPath = request.getServletContext().getRealPath("");
                String uploadFilePath = applicationPath + File.separator + "uploaded_resumes";
                
                File uploadFolder = new File(uploadFilePath);
                if (!uploadFolder.exists()) {
                    uploadFolder.mkdirs();
                }
                
                // Write file data bytes down to destination directory pathway reference
                filePart.write(uploadFilePath + File.separator + savedFileName);
                
                // Execute SQL Query to permanently record structural updates to relational db state
                String updateSql = "UPDATE users SET full_name = ?, resume_path = ? WHERE id = ?";
                try (Connection conn = DBConnection.getConnection(); PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setString(1, fullName);
                    updateStmt.setString(2, savedFileName);
                    updateStmt.setInt(3, user.getId());
                    updateStmt.executeUpdate();
                    
                    // Synchronize local attributes assigned to active user model session
                    user.setFullName(fullName);
                    user.setResumePath(savedFileName);
                    
                    session.setAttribute("successMsg", "Profile metrics initialized and mapped successfully!");
                    response.sendRedirect("candidate/candidatePortal.jsp");
                    return;
                } catch (SQLException e) {
                    request.setAttribute("error", "Database profile pipeline sync update failure: " + e.getMessage());
                    request.getRequestDispatcher("candidate/completeProfile.jsp").forward(request, response);
                    return;
                }
            } else {
                request.setAttribute("error", "Invalid Document Format. Profile update abort; only PDF Mode supported.");
                request.getRequestDispatcher("candidate/completeProfile.jsp").forward(request, response);
                return;
            }
        }

        // ================= SYSTEM LOGIN ENGINE DISPATCH =================
        String userIn = request.getParameter("username");
        String passIn = request.getParameter("password");

        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE username = ? AND password = ?")) {
            stmt.setString(1, userIn);
            stmt.setString(2, passIn);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    // UPDATED: Fetches the 'resume_path' value out of your row records
                    User user = new User(
                        rs.getInt("id"), 
                        rs.getString("username"), 
                        rs.getString("role"), 
                        rs.getString("full_name"),
                        rs.getString("email"),
                        rs.getString("resume_path") // READ FROM COLUMN DATA INDEX
                    );
                    
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