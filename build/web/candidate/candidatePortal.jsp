<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.recruitx.model.User, com.recruitx.config.DBConnection, java.sql.*"%>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Candidate Portal | RecruitX</title>
        <link rel="stylesheet" type="text/css" href="../css/styles.css">
    </head>
    <body>
        <%@include file="../includes/header.jsp" %>

        <% if (session.getAttribute("successMsg") != null) {%>
        <div class="msg-banner"><%= session.getAttribute("successMsg")%></div>
        <% session.removeAttribute("successMsg"); %>
        <% } %>

        <div class="main-layout">
            <div class="card">
                <h3>💼 Live Vacancy Listings Board</h3>
                <table>
                    <thead><tr><th>Job Title</th><th>Requirements</th><th>Action</th></tr></thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery("SELECT * FROM jobs WHERE status = 'OPEN'")) {
                                while (rs.next()) {
                        %>
                        <tr>
                            <td><b><%= rs.getString("title")%></b><br><small><%= rs.getString("description")%></small></td>
                            <td><%= rs.getString("requirements")%></td>
                            <td>
                                <form action="../RecruitmentEngine" method="POST" style="margin:0;">
                                    <input type="hidden" name="action" value="applyJob" />
                                    <input type="hidden" name="jobId" value="<%= rs.getInt("id")%>" />
                                    <input type="hidden" name="resumeName" value="Resume_<%= user.getUsername()%>.pdf" />
                                    <button type="submit" class="btn-success" style="padding:6px 12px; font-size:12px;">Apply</button>
                                </form>
                            </td>
                        </tr>
                        <%      }
                            } catch (Exception e) {
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <div class="card">
                <h3>📊 Your Job Application Pipelines Tracking</h3>
                <table>
                    <thead><tr><th>Target Job</th><th>Status</th><th>Screening Keyword Analysis</th></tr></thead>
                    <tbody>
                        <%
                            String sql = "SELECT a.status, j.title, s.fit_score, s.keyword_matches FROM applications a "
                                    + "JOIN jobs j ON a.job_id = j.id "
                                    + "LEFT JOIN screening_results s ON s.application_id = a.id WHERE a.candidate_id = ?";
                            try (Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
                                stmt.setInt(1, user.getId());
                                try (ResultSet rs = stmt.executeQuery()) {
                                    while (rs.next()) {
                                        String status = rs.getString("status");
                                        String badgeClass = "badge-sub";
                                        if ("SHORTLISTED".equals(status)) {
                                            badgeClass = "badge-short";
                                        }
                                        if ("REJECTED".equals(status))
                                            badgeClass = "badge-rej";
                        %>
                        <tr>
                            <td><b><%= rs.getString("title")%></b></td>
                            <td><span class="status-badge <%= badgeClass%>"><%= status%></span></td>
                            <td>
                                <% if (rs.getString("keyword_matches") != null) {%>
                                Score: <b><%= rs.getInt("fit_score")%>%</b><br><small>Matches: <%= rs.getString("keyword_matches")%></small>
                                <% } else { %>
                                <span style="color:gray; font-size:12px;">EDA screening engine compiling...</span>
                                <% } %>
                            </td>
                        </tr>
                        <%          }
                                }
                            } catch (Exception e) {
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </body>
</html>