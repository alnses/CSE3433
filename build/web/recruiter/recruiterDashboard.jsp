<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.recruitx.model.User, com.recruitx.config.DBConnection, java.sql.*"%>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !"RECRUITER".equals(user.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Recruiter Command Console | RecruitX</title>
        <link rel="stylesheet" type="text/css" href="../css/styles.css">
    </head>
    <body>
        <%@include file="../includes/header.jsp" %>

        <% if (session.getAttribute("successMsg") != null) {%>
        <div class="msg-banner"><%= session.getAttribute("successMsg")%></div>
        <% session.removeAttribute("successMsg"); %>
        <% } %>

        <div class="main-layout grid-wide">
            <div>
                <div class="card">
                    <h3>📢 Publish New Job Opening Vacancy</h3>
                    <form action="../RecruitmentEngine" method="POST">
                        <input type="hidden" name="action" value="postJob" />
                        <label>Job Designation Title</label>
                        <input type="text" name="title" placeholder="e.g. Senior Software Architect" required />
                        <label>Core Scope Description</label>
                        <textarea name="description" rows="3" required></textarea>
                        <label>Pre-defined Keywords Filter Set</label>
                        <input type="text" name="requirements" placeholder="e.g. Java, Cloud Computing, Architecture" required />
                        <button type="submit">Publish & Broadcast Job</button>
                    </form>
                </div>

                <div class="card">
                    <h3>⚡ RabbitMQ Live Message Stream Log (EDA Pipeline Audit)</h3>
                    <div style="max-height:220px; overflow-y:auto; font-family:monospace; font-size:12px; background:#1e293b; color:#38bdf8; padding:15px; border-radius:8px;">
                        <%
                            try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery("SELECT * FROM event_logs ORDER BY id DESC")) {
                                while (rs.next()) {
                        %>
                        [<%= rs.getTimestamp("processed_at")%>] EVENT: <b><%= rs.getString("event_type")%></b> -> Payload: <%= rs.getString("payload")%><br><br>
                        <%
                                }
                            } catch (Exception e) {
                                out.print("Error polling event stream.");
                            }
                        %>
                    </div>
                </div>
            </div>

            <div class="card">
                <h3>📥 Inbound Candidates Tracking funnel</h3>
                <table>
                    <thead><tr><th>Candidate</th><th>Applied Role</th><th>Status</th><th>Automated Match Metrics</th></tr></thead>
                    <tbody>
                        <%
                            String query = "SELECT u.full_name, j.title, a.status, s.fit_score, s.keyword_matches FROM applications a "
                                    + "JOIN users u ON a.candidate_id = u.id "
                                    + "JOIN jobs j ON a.job_id = j.id "
                                    + "LEFT JOIN screening_results s ON s.application_id = a.id ORDER BY a.id DESC";
                            try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(query)) {
                                while (rs.next()) {
                                    String status = rs.getString("status");
                                    String badge = "badge-sub";
                                    if ("SHORTLISTED".equals(status)) {
                                        badge = "badge-short";
                                    }
                                    if ("REJECTED".equals(status)) {
                                    badge = "badge-rej";
                                }
                                Mosc;%>
                        <tr>
                            <td><b><%= rs.getString("full_name")%></b></td>
                            <td><%= rs.getString("title")%></td>
                            <td><span class="status-badge <%= badge%>"><%= status%></span></td>
                            <td>
                                <% if (rs.getString("keyword_matches") != null) {%>
                                Match: <b style="color:#10b981;"><%= rs.getInt("fit_score")%>%</b><br><small><%= rs.getString("keyword_matches")%></small>
                                <% } else { %>
                                <span style="color:orange;">Evaluating...</span>
                                <% } %>
                            </td>
                        </tr>
                        <%
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