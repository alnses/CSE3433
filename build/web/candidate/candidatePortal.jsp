<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.recruitx.model.User, com.recruitx.config.DBConnection, java.sql.*"%>

<%
    User user = (User) session.getAttribute("currentUser");

    if (user == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    // Safely structure credential fallback strings
    String email = (user.getEmail() != null && !user.getEmail().trim().isEmpty()) ? user.getEmail() : "Not Provided";
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Candidate Portal | RecruitX</title>

        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/styles.css">
    </head>

    <body>

        <jsp:include page="../includes/header.jsp" />

        <% if (session.getAttribute("successMsg") != null) {%>
        <div class="portal-main" style="margin-bottom: -40px; margin-top: 20px;">
            <div class="alert-banner">
                <%= session.getAttribute("successMsg")%>
            </div>
        </div>
        <%
                session.removeAttribute("successMsg");
            }
        %>

        <div class="portal-main">

            <div class="dashboard-alert">
                <div>
                    <p class="alert-title">
                        Candidate Recruitment Workspace Active
                    </p>
                    <p class="alert-desc">
                        Browse vacancies, submit applications, and monitor automated resume screening progress in real time.
                    </p>
                </div>
            </div>

            <div class="workspace-container" style="margin: 0 auto 35px auto; padding: 0;">

                <div class="card-panel">
                    <div class="panel-header">
                        <h3 class="panel-title">Personal Metrics Profile</h3>
                        <span class="badge-stream">Verified Candidate</span>
                    </div>
                    <div class="accent-bar" style="margin-top: -20px; margin-bottom: 20px;"></div>

                    <div class="form-group">
                        <label style="color: var(--primary);">Full Name</label>
                        <div class="job-title-main" style="margin-top: 4px;"><%= user.getFullName()%></div>
                    </div>

                    <div class="form-group">
                        <label style="color: var(--primary);">Email Address / Account ID</label>
                        <p style="margin: 4px 0; font-size: 0.95rem; color: var(--text-dark); font-weight: 600;"><%= email%></p>
                    </div>
                </div>

                <div class="card-panel">
                    <div class="panel-header">
                        <h3 class="panel-title">Curriculum Vitae Repository</h3>
                        <span class="badge-stream broker-active">Active Mapped</span>
                    </div>
                    <div class="accent-bar" style="margin-top: -20px; margin-bottom: 20px;"></div>

                    <p class="panel-description" style="font-size: 0.85rem;">
                        Your default profile attachment handles background parameters used by the asynchronous validation event workflows.
                    </p>

                    <div class="requirements-box" style="margin-bottom: 15px; border-left: 3px solid var(--accent); background: #f8fafc;">
                        <strong style="display:block; font-size:0.75rem; text-transform:uppercase; color:var(--text-muted); margin-bottom: 2px;">Active Document Tracking ID:</strong>
                        <span style="font-family: monospace; font-size:0.88rem; color: var(--primary); font-weight:700;">
                            <% if (user.getResumePath() != null && !user.getResumePath().trim().isEmpty()) {%>
                            📄 Resume_<%= user.getUsername()%>.pdf
                            <% } else { %>
                            <span style="color: red; font-style: italic;">⚠️ No Resume Uploaded</span>
                            <% }%>
                        </span>
                    </div>
                </div>

            </div>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-value" style="font-size: 1.2rem; line-height: 1.6;"><%= user.getFullName()%></div>
                    <div class="stat-label">Active Candidate Profile</div>
                </div>

                <div class="stat-card">
                    <div class="stat-value">Active</div>
                    <div class="stat-label">Account Status</div>
                </div>

                <div class="stat-card">
                    <div class="stat-value">EDA</div>
                    <div class="stat-label">Processing Engine</div>
                </div>
            </div>

            <div id="vacancySection" class="section-wrapper">
                <div class="section-heading-group">
                    <h2>Live Vacancy Listings Board</h2>
                </div>

                <h2>Notifications</h2>

                <table class="enterprise-table">
                    <tr>
                        <th>Message</th>
                        <th>Date</th>
                    </tr>

                    <%
                        String notifSql
                                = "SELECT * FROM notifications "
                                + "WHERE candidate_id=? "
                                + "ORDER BY created_at DESC";

                        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps
                                = conn.prepareStatement(notifSql)) {

                            ps.setInt(1, user.getId());

                            ResultSet rs = ps.executeQuery();

                            while (rs.next()) {
                    %>

                    <tr>
                        <td><%= rs.getString("message")%></td>
                        <td><%= rs.getTimestamp("created_at")%></td>
                    </tr>

                    <%
                            }
                        } catch (Exception e) {
                            out.println(e.getMessage());
                        }
                    %>

                </table>
                <div class="table-responsive-card">
                    <table class="enterprise-table">
                        <thead>
                            <tr>
                                <th>Job Position</th>
                                <th>Technical Requirements Profile</th>
                                <th style="width: 200px; text-align: right;">Application Route</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try (
                                        Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery("SELECT * FROM jobs")) {
                                    boolean hasJobs = false;
                                    while (rs.next()) {
                                        hasJobs = true;
                                        String reqs = rs.getString("requirements");
                            %>
                            <tr>
                                <td>
                                    <div class="job-title-main"><%= rs.getString("title")%></div>
                                    <p class="job-desc-text"><%= rs.getString("description")%></p>
                                </td>
                                <td>
                                    <div class="pill-container">
                                        <%
                                            if (reqs != null && !reqs.trim().isEmpty()) {
                                                for (String skill : reqs.split(",")) {
                                        %>
                                        <span class="tech-pill architecture"><%= skill.trim()%></span>
                                        <%
                                            }
                                        } else {
                                        %>
                                        <span class="tech-pill">General Skills</span>
                                        <%  }%>
                                    </div>
                                </td>
                                <td style="text-align: right; vertical-align: middle;">
                                    <%
                                        // Business Logic Check: Evaluate if the active session user has completed their profile
                                        boolean hasResume = (user.getResumePath() != null && !user.getResumePath().trim().isEmpty());
                                        boolean isProfileComplete = hasResume && (user.getFullName() != null && !user.getFullName().trim().isEmpty());

                                        if (isProfileComplete) {
                                    %>
                                    <form action="${pageContext.request.contextPath}/RecruitmentEngine" method="POST" style="margin: 0;">
                                        <input type="hidden" name="action" value="applyJob">
                                        <input type="hidden" name="jobId" value="<%= rs.getInt("id")%>">
                                        <input type="hidden" name="resumeName" value="Resume_<%= user.getUsername()%>.pdf">
                                        <button type="submit" class="btn-table-apply">Apply Now</button>
                                    </form>
                                    <% } else { %>
                                    <button type="button" class="btn-table-apply" onclick="checkIncompleteProfile()">Apply Now</button>
                                    <% } %>
                                </td>
                            </tr>
                            <%
                                }
                                if (!hasJobs) {
                            %>
                            <tr>
                                <td colspan="3" class="empty-state">
                                    <h3>No Openings Available</h3>
                                    <p>Check back later for active job distribution listings.</p>
                                </td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='3' class='empty-state'><h3>Data Pipeline Interrupted</h3><p>" + e.getMessage() + "</p></td></tr>");
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="section-wrapper" style="margin-top: 40px;">
                <div class="section-heading-group">
                    <h2>Application Pipeline Monitoring</h2>
                </div>

                <div class="table-responsive-card">
                    <table class="enterprise-table">
                        <thead>
                            <tr>
                                <th>Job Position Reference</th>
                                <th style="width: 200px;">Current Status</th>
                                <th style="width: 350px;">Asynchronous Screening Analysis Metrics</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                String pipelineSql = "SELECT a.status, j.title, s.fit_score, s.keyword_matches "
                                        + "FROM applications a "
                                        + "JOIN jobs j ON a.job_id=j.id "
                                        + "LEFT JOIN screening_results s ON s.application_id=a.id "
                                        + "WHERE a.candidate_id=?";

                                try (
                                        Connection conn = DBConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(pipelineSql)) {
                                    stmt.setInt(1, user.getId());
                                    try (ResultSet rs = stmt.executeQuery()) {
                                        boolean hasApplications = false;
                                        while (rs.next()) {
                                            hasApplications = true;
                                            String status = rs.getString("status");
                                            String badgeClass = status != null ? status.toLowerCase() : "submitted";
                            %>
                            <tr>
                                <td style="vertical-align: middle;">
                                    <div class="job-title-main" style="margin: 0;"><%= rs.getString("title")%></div>
                                </td>
                                <td style="vertical-align: middle;">
                                    <span class="status-badge <%= badgeClass%>">
                                        <%= status%>
                                    </span>
                                </td>
                                <td style="vertical-align: middle; font-size: 0.9rem; line-height: 1.4;">
                                    <% if (rs.getString("keyword_matches") != null) {%>
                                    <div style="margin-bottom: 4px;">Fit Capability Score: <b style="color: var(--accent);"><%= rs.getInt("fit_score")%>%</b></div>
                                    <span class="engine-terminal-badge" style="font-size: 0.72rem; display: inline-block;">
                                        Matches: <%= rs.getString("keyword_matches")%>
                                    </span>
                                    <% } else { %>
                                    <span style="color: var(--text-muted); font-style: italic;" class="pipeline-indicator-group">
                                        <span class="live-pulse-dot"></span> Screening Engine Processing...
                                    </span>
                                    <% } %>
                                </td>
                            </tr>
                            <%
                                }
                                if (!hasApplications) {
                            %>
                            <tr>
                                <td colspan="3" class="empty-state">
                                    <h3>No Applications Filed</h3>
                                    <p>Your submitted profiles will track inside this ledger panel.</p>
                                </td>
                            </tr>
                            <%
                                        }
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='3' class='empty-state'><h3>Ledger Compile Error</h3><p>" + e.getMessage() + "</p></td></tr>");
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="section-wrapper" style="margin-top: 40px;">
                <div class="section-heading-group">
                    <h2>Event Processing Monitor</h2>
                    <span class="badge-stream broker-active">
                        RabbitMQ Simulation Active
                    </span>
                </div>

                <div class="card-panel">
                    <div class="event-log-container">
                        [INFO] Candidate Portal Connected Successfully...<br>
                        [EVENT] ApplicationReceived Listener Subscribed...<br>
                        [SERVICE] Resume Screening Engine Online...<br>
                        [SERVICE] Notification System Hook Dispatched...<br>
                        [STATUS] Awaiting Telemetry Pipeline Stream Events...<br>
                    </div>
                </div>
            </div>

        </div>

        <script type="text/javascript">
            function checkIncompleteProfile() {
                alert("Action Required:\nYour recruitment profile metrics are currently unmapped.\n\nPlease complete your personal details and upload your PDF Resume before filing job applications.");
                window.location.href = "completeProfile.jsp";
            }
        </script>
    </body>
</html>