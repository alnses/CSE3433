package com.recruitx.controller;

import com.recruitx.config.DBConnection;
import com.recruitx.config.SimulatedRabbitMQ;
import com.recruitx.model.User;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
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

            } else if ("applyJob".equals(action)) {

                int jobId = Integer.parseInt(request.getParameter("jobId"));

                /*
        SERVER-SIDE PROFILE VALIDATION
                 */
                if (!user.isProfileCompleted()
                        || user.getFullName() == null
                        || user.getFullName().trim().isEmpty()
                        || user.getPhone() == null
                        || user.getPhone().trim().isEmpty()
                        || user.getAddress() == null
                        || user.getAddress().trim().isEmpty()
                        || user.getResumePath() == null
                        || user.getResumePath().trim().isEmpty()) {

                    session.setAttribute(
                            "successMsg",
                            "⚠ Please complete your profile before applying."
                    );

                    response.sendRedirect("candidate/completeProfile.jsp");
                    return;
                }

                /*
        CHECK JOB STATUS
                 */
                String jobSql = "SELECT status FROM jobs WHERE id=?";

                try (PreparedStatement jobStmt = conn.prepareStatement(jobSql)) {

                    jobStmt.setInt(1, jobId);

                    ResultSet jobRs = jobStmt.executeQuery();

                    if (jobRs.next()) {

                        String status = jobRs.getString("status");

                        if (!"OPEN".equalsIgnoreCase(status)) {

                            session.setAttribute(
                                    "successMsg",
                                    "This vacancy is no longer open."
                            );

                            response.sendRedirect(
                                    "candidate/candidatePortal.jsp"
                            );

                            return;
                        }
                    }
                }

                /*
        DUPLICATE APPLICATION CHECK
                 */
                String duplicateSql
                        = "SELECT COUNT(*) "
                        + "FROM applications "
                        + "WHERE candidate_id=? "
                        + "AND job_id=?";

                try (PreparedStatement duplicateStmt
                        = conn.prepareStatement(duplicateSql)) {

                    duplicateStmt.setInt(1, user.getId());
                    duplicateStmt.setInt(2, jobId);

                    ResultSet duplicateRs
                            = duplicateStmt.executeQuery();

                    if (duplicateRs.next()
                            && duplicateRs.getInt(1) > 0) {

                        session.setAttribute(
                                "successMsg",
                                "You have already applied for this position."
                        );

                        response.sendRedirect(
                                "candidate/candidatePortal.jsp"
                        );

                        return;
                    }
                }

                /*
        PUBLISH APPLICATION EVENT
                 */
                String payload
                        = "jobId:" + jobId
                        + ",candidateId:" + user.getId()
                        + ",resume:" + user.getResumePath();

                SimulatedRabbitMQ.publishEvent(
                        "ApplicationReceived",
                        payload
                );

                session.setAttribute(
                        "successMsg",
                        "Application submitted successfully. Screening process started."
                );

                response.sendRedirect(
                        "candidate/candidatePortal.jsp"
                );

            } else if ("scheduleInterview".equals(action)) {

                int applicationId = Integer.parseInt(
                        request.getParameter("applicationId"));

                String interviewDate
                        = request.getParameter("interviewDate");

                String meetingLink
                        = request.getParameter("meetingLink");

                /*
        Check whether application exists
                 */
                String checkSql
                        = "SELECT COUNT(*) "
                        + "FROM applications "
                        + "WHERE id=?";

                try (PreparedStatement checkStmt
                        = conn.prepareStatement(checkSql)) {

                    checkStmt.setInt(1, applicationId);

                    ResultSet rs = checkStmt.executeQuery();

                    if (rs.next() && rs.getInt(1) == 0) {

                        session.setAttribute(
                                "successMsg",
                                "Application ID not found."
                        );

                        response.sendRedirect(
                                "recruiter/scheduleInterview.jsp");

                        return;
                    }
                }

                /*
        Save interview
                 */
                String insertSql
                        = "INSERT INTO interviews "
                        + "(application_id, schedule_time, meeting_link) "
                        + "VALUES (?, ?, ?)";

                try (PreparedStatement stmt
                        = conn.prepareStatement(insertSql)) {

                    stmt.setInt(1, applicationId);
                    stmt.setString(2, interviewDate);
                    stmt.setString(3, meetingLink);

                    stmt.executeUpdate();
                }

                /*
        Publish RabbitMQ Event
                 */
                String payload
                        = "applicationId:" + applicationId
                        + ",schedule:" + interviewDate
                        + ",meeting:" + meetingLink;

                SimulatedRabbitMQ.publishEvent(
                        "InterviewScheduled",
                        payload
                );

                session.setAttribute(
                        "successMsg",
                        "Interview scheduled successfully and notification dispatched!"
                );

                response.sendRedirect(
                        "recruiter/scheduleInterview.jsp");

                return;
                
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
