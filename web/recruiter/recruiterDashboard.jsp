<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.recruitx.model.User"%>

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
        <meta charset="UTF-8">
        <title>RecruitX Recruiter Dashboard</title>

        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/styles.css">
    </head>

    <body>

        <jsp:include page="../includes/header.jsp" />

        <main class="portal-main fade-in">

            <div class="dashboard-alert">
                <div>
                    <p class="alert-title">
                        Recruitment Operations Centre Active
                    </p>
                    <p class="alert-desc">
                        RecruitX Event Bus is currently monitoring recruitment workflows and processing incoming events.
                    </p>
                </div>
            </div>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-value">12</div>
                    <div class="stat-label">Open Jobs</div>
                </div>

                <div class="stat-card">
                    <div class="stat-value">56</div>
                    <div class="stat-label">Applications</div>
                </div>

                <div class="stat-card">
                    <div class="stat-value">18</div>
                    <div class="stat-label">Shortlisted</div>
                </div>

                <div class="stat-card">
                    <div class="stat-value">8</div>
                    <div class="stat-label">Interviews</div>
                </div>
            </div>

            <div class="section-wrapper">
                <div class="section-heading-group">
                    <h2>Recruitment Management</h2>
                </div>

                <div class="dashboard-grid">
                    <div class="dashboard-card">
                        <h3>Create Job Posting</h3>
                        <p>
                            Publish new vacancies and trigger the JobPosted event.
                        </p>
                        <a href="createJob.jsp">
                            Open Module
                        </a>
                    </div>

                    <div class="dashboard-card">
                        <h3>Candidate Management</h3>
                        <p>
                            Review candidate applications and update recruitment status.
                        </p>
                        <a href="candidateManagement.jsp">
                            Open Module
                        </a>
                    </div>

                    <div class="dashboard-card">
                        <h3>Interview Scheduling</h3>
                        <p>
                            Schedule candidate interviews and trigger InterviewRequested events.
                        </p>
                        <a href="scheduleInterview.jsp">
                            Open Module
                        </a>
                    </div>
                </div>
            </div>

            <div class="section-wrapper">
                <div class="section-heading-group">
                    <h2>Event Bus Monitoring</h2>
                    <span class="badge-stream broker-active">
                        RabbitMQ Simulation Active
                    </span>
                </div>

                <div class="card-panel">
                    <div class="event-log-container">
                        [INFO] RecruitX Event Bus Initialized...<br>
                        [EVENT] JobPosted Event Waiting...<br>
                        [EVENT] ApplicationReceived Event Waiting...<br>
                        [EVENT] InterviewRequested Event Waiting...<br>
                        [SERVICE] Notification Consumer Ready...<br>
                        [SERVICE] Resume Screening Consumer Ready...<br>
                        [SERVICE] Analytics Consumer Ready...<br>
                    </div>
                </div>
            </div>

        </main>

        <footer class="portal-footer">
            <div class="footer-container">
                <div>
                    RecruitX Recruitment Management Platform
                </div>
                <div class="footer-links">
                    <span class="tag-version">
                        v1.0
                    </span>
                    <span>
                        Event Driven Architecture
                    </span>
                </div>
            </div>
        </footer>

    </body>
</html>