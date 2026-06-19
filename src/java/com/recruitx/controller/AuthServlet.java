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
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
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

                String insertSql
                        = "INSERT INTO users "
                        + "(username,password,role,full_name,email,profile_completed) "
                        + "VALUES (?,?,?,?,?,0)";
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

        // ================= UPDATE CANDIDATE PROFILE HANDLER =================
        if ("updateProfile".equals(action)) {

            HttpSession session = request.getSession(false);
            User user = (session != null)
                    ? (User) session.getAttribute("currentUser")
                    : null;

            if (user == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            String fullName = request.getParameter("fullName");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");

            Part filePart = request.getPart("resumePdf");

            String contentDisp = filePart.getHeader("content-disposition");
            String fileName = "";

            for (String token : contentDisp.split(";")) {
                if (token.trim().startsWith("filename")) {
                    fileName = token.substring(
                            token.indexOf("=") + 2,
                            token.length() - 1
                    );
                }
            }

            /*
        Keep existing resume if user does not upload a new one
             */
            String savedFileName = user.getResumePath();

            /*
        User uploads a new resume
             */
            if (fileName != null && !fileName.trim().isEmpty()) {

                if (!fileName.toLowerCase().endsWith(".pdf")) {

                    request.setAttribute(
                            "error",
                            "Only PDF resumes are allowed."
                    );

                    request.getRequestDispatcher(
                            "candidate/completeProfile.jsp"
                    ).forward(request, response);

                    return;
                }

                savedFileName = "Resume_"
                        + user.getUsername()
                        + ".pdf";

                String applicationPath
                        = request.getServletContext().getRealPath("");

                String uploadFilePath
                        = applicationPath
                        + File.separator
                        + "uploaded_resumes";

                File uploadFolder = new File(uploadFilePath);

                if (!uploadFolder.exists()) {
                    uploadFolder.mkdirs();
                }

                filePart.write(
                        uploadFilePath
                        + File.separator
                        + savedFileName
                );
            }

            /*
        First-time users MUST upload resume
             */
            if (savedFileName == null
                    || savedFileName.trim().isEmpty()) {

                request.setAttribute(
                        "error",
                        "Please upload your resume (PDF)."
                );

                request.getRequestDispatcher(
                        "candidate/completeProfile.jsp"
                ).forward(request, response);

                return;
            }

            /*
        Validate personal details
             */
            if (fullName == null || fullName.trim().isEmpty()
                    || phone == null || phone.trim().isEmpty()
                    || address == null || address.trim().isEmpty()) {

                request.setAttribute(
                        "error",
                        "Please complete all required fields."
                );

                request.getRequestDispatcher(
                        "candidate/completeProfile.jsp"
                ).forward(request, response);

                return;
            }

            /*
        Update database
             */
            String updateSql
                    = "UPDATE users "
                    + "SET full_name=?, "
                    + "phone=?, "
                    + "address=?, "
                    + "resume_path=?, "
                    + "profile_completed=1 "
                    + "WHERE id=?";

            try (Connection conn = DBConnection.getConnection(); PreparedStatement updateStmt
                    = conn.prepareStatement(updateSql)) {

                updateStmt.setString(1, fullName);
                updateStmt.setString(2, phone);
                updateStmt.setString(3, address);
                updateStmt.setString(4, savedFileName);
                updateStmt.setInt(5, user.getId());

                updateStmt.executeUpdate();

                /*
            Update session user
                 */
                user.setFullName(fullName);
                user.setPhone(phone);
                user.setAddress(address);
                user.setResumePath(savedFileName);
                user.setProfileCompleted(true);

                session.setAttribute("currentUser", user);
                session.setAttribute(
                        "successMsg",
                        "Profile completed successfully!"
                );

                response.sendRedirect(
                        "candidate/candidatePortal.jsp"
                );

                return;

            } catch (SQLException e) {

                request.setAttribute(
                        "error",
                        "Database update failed: "
                        + e.getMessage()
                );

                request.getRequestDispatcher(
                        "candidate/completeProfile.jsp"
                ).forward(request, response);

                return;
            }
        }
        // ================= SYSTEM LOGIN ENGINE DISPATCH =================
        String userIn = request.getParameter("username");
        String passIn = request.getParameter("password");

        try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE username = ? AND password = ?")) {
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
                            rs.getString("resume_path"),
                            rs.getString("phone"),
                            rs.getString("address"),
                            rs.getBoolean("profile_completed")
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
