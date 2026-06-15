<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="com.recruitx.config.DBConnection"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Candidate Management | RecruitX</title>
        
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/styles.css">
    </head>

    <body>

        <jsp:include page="../includes/header.jsp" />

        <main class="portal-main">
            
            <div class="section-wrapper">
                <div class="section-heading-group">
                    <h2>Candidate Applications</h2>
                </div>
                <p class="panel-description">
                    Review incoming job applications, update processing milestones, and broadcast candidate status metrics through the RabbitMQ pipeline.
                </p>
            </div>

            <div class="table-responsive-card">
                <table class="enterprise-table">
                    <thead>
                        <tr>
                            <th style="width: 80px;">ID</th>
                            <th>Candidate Name</th>
                            <th style="width: 180px;">Current Status</th>
                            <th style="width: 320px; text-align: right;">Action Control Panel</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Connection conn = DBConnection.getConnection();

                                String sql = "SELECT a.id, u.full_name, a.status "
                                           + "FROM applications a "
                                           + "JOIN users u ON a.candidate_id = u.id";

                                PreparedStatement stmt = conn.prepareStatement(sql);
                                ResultSet rs = stmt.executeQuery();

                                while (rs.next()) {
                                    String currentStatus = rs.getString("status");
                                    
                                    // Safeguard null states and convert status to lowercase for CSS binding classes
                                    String badgeClass = currentStatus != null ? currentStatus.toLowerCase() : "submitted";
                        %>
                        <tr>
                            <td style="font-weight: 700; color: var(--text-muted); vertical-align: middle;">
                                #<%= rs.getInt("id")%>
                            </td>

                            <td style="vertical-align: middle;">
                                <div class="job-title-main"><%= rs.getString("full_name")%></div>
                                <span class="engine-terminal-badge">Candidate Application Pipeline</span>
                            </td>

                            <td style="vertical-align: middle;">
                                <span class="status-badge <%= badgeClass %>">
                                    <%= currentStatus %>
                                </span>
                            </td>

                            <td style="vertical-align: middle;">
                                <form action="${pageContext.request.contextPath}/RecruitmentEngine" method="post" class="action-group" style="justify-content: flex-end; margin: 0;">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="applicationId" value="<%= rs.getInt("id")%>">

                                    <select name="status" class="form-control-select">
                                        <option value="SHORTLISTED" <%= "SHORTLISTED".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>SHORTLISTED</option>
                                        <option value="INTERVIEW" <%= "INTERVIEW".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>INTERVIEW</option>
                                        <option value="REJECTED" <%= "REJECTED".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>REJECTED</option>
                                        <option value="ACCEPTED" <%= "ACCEPTED".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>ACCEPTED</option>
                                    </select>

                                    <button type="submit" class="btn-table-apply">
                                        Update
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%
                                }
                                conn.close();
                            } catch (Exception e) {
                                out.println("<tr><td colspan='4' class='empty-state'><h3>System Error Encountered</h3><p>" + e.getMessage() + "</p></td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <br>
            <a href="recruiterDashboard.jsp" class="btn-signout" style="display: inline-block; margin-top: 15px; text-decoration: none;">
                &larr; Back to Dashboard
            </a>

        </main>

    </body>
</html>