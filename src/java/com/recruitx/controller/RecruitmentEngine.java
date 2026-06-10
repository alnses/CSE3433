package com.recruitx.controller;

import com.recruitx.config.DBConnection;
import com.recruitx.config.SimulatedRabbitMQ;
import com.recruitx.model.User;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RecruitmentEngine")
public class RecruitmentEngine extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        String action = request.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {
            if ("postJob".equals(action)) { // FR01 - Recruiter issues vacancy listings
                String title = request.getParameter("title");
                String desc = request.getParameter("description");
                String reqs = request.getParameter("requirements");

                String insertSql = "INSERT INTO jobs (title, description, requirements, recruiter_id) VALUES (?, ?, ?, ?)";
                try (PreparedStatement stmt = conn.prepareStatement(insertSql)) {
                    stmt.setString(1, title);
                    stmt.setString(2, desc);
                    stmt.setString(3, reqs);
                    stmt.setInt(4, user.getId());
                    stmt.executeUpdate();
                }

                // PUBLISH THE ASYNCHRONOUS BACKGROUND EVENT VIA RABBITMQ STREAM
                SimulatedRabbitMQ.publishEvent("JobPosted", "title:" + title);
                session.setAttribute("successMsg", "Job Distributed to Public Boards via RabbitMQ!");
                response.sendRedirect("recruiter/recruiterDashboard.jsp");

            } else if ("applyJob".equals(action)) { // FR02 - Candidate application submission
                int jobId = Integer.parseInt(request.getParameter("jobId"));
                String resumeName = request.getParameter("resumeName");

                // CRITICAL ASYNCHRONOUS EDA EVENT: Publish data straight to the broker
                String payload = "jobId:" + jobId + ",candidateId:" + user.getId() + ",resume:" + resumeName;
                SimulatedRabbitMQ.publishEvent("ApplicationReceived", payload);

                session.setAttribute("successMsg", "Application Received Event Fired! Background screening active.");
                response.sendRedirect("candidate/candidatePortal.jsp");

            } else if ("updateStatus".equals(action)) { // NEW: Handles status updates from candidateManagement.jsp
                String applicationIdStr = request.getParameter("applicationId");
                String newStatus = request.getParameter("status");

                if (applicationIdStr != null && newStatus != null) {
                    int applicationId = Integer.parseInt(applicationIdStr);

                    // 1. Update status in the database (Assuming table is 'applications' or 'candidate_applications')
                    String updateSql = "UPDATE applications SET status = ? WHERE id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                        stmt.setString(1, newStatus);
                        stmt.setInt(2, applicationId);
                        stmt.executeUpdate();
                    }

                    // 2. Asynchronous EDA Event: Publish status update to RabbitMQ broker
                    String payload = "applicationId:" + applicationId + ",status:" + newStatus + ",recruiterId:" + user.getId();
                    SimulatedRabbitMQ.publishEvent("ApplicationStatusUpdated", payload);

                    session.setAttribute("successMsg", "Candidate status updated and event published successfully!");
                }
                
                // 3. Crucial redirect to prevent the blank page loop
                response.sendRedirect("recruiter/candidateManagement.jsp");
            }
            
        } catch (SQLException e) {
            throw new ServletException("Database system connection transaction failure", e);
        } catch (Exception e) {
            throw new ServletException("General processing exception inside EDA workflow", e);
        }
    }
}