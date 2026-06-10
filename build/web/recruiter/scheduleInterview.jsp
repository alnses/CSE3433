<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.recruitx.model.User"%>
<%
    // Session Guard Layer
    User user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Schedule Interview | RecruitX</title>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/styles.css">
    </head>

    <body>

        <jsp:include page="../includes/header.jsp" />

        <main class="portal-main">
            
            <div class="section-wrapper">
                <div class="section-heading-group">
                    <h2>Interview Scheduling</h2>
                </div>
                <p class="panel-description">
                    Assign a specific evaluation date, clock window, and corporate teleconferencing web link to a candidate milestone. Submitting this form activates back-end notification event consumers.
                </p>
            </div>

            <div class="form-card" style="margin: 0 auto;">
                <form action="${pageContext.request.contextPath}/RecruitmentEngine" method="post">

                    <input type="hidden" name="action" value="scheduleInterview">

                    <div class="form-group">
                        <label for="applicationId">Application ID Reference</label>
                        <input type="number" 
                               id="applicationId" 
                               name="applicationId" 
                               class="form-control" 
                               placeholder="e.g., 1" 
                               required>
                        <span class="form-help-text">Input the database identifier mapped directly to the candidate application.</span>
                    </div>

                    <div class="form-group">
                        <label for="interviewDate">Target Date & Time Window</label>
                        <input type="datetime-local" 
                               id="interviewDate" 
                               name="interviewDate" 
                               class="form-control" 
                               required>
                        <span class="form-help-text">Select a time corresponding to the default business evaluation shift layout.</span>
                    </div>

                    <div class="form-group">
                        <label for="meetingLink">Corporate Meeting Link (URL)</label>
                        <input type="text" 
                               id="meetingLink" 
                               name="meetingLink" 
                               class="form-control" 
                               placeholder="e.g., https://teams.microsoft.com/l/meetup-join/..." 
                               required>
                        <span class="form-help-text">Paste the full teleconference link (Google Meet, Microsoft Teams, or Zoom).</span>
                    </div>

                    <button type="submit" class="btn-broadcast" style="margin-top: 10px;">
                        Schedule Interview & Dispatch Notifications
                    </button>

                </form>
            </div>

            <br>
            <a href="recruiterDashboard.jsp" class="btn-signout" style="display: inline-block; margin-top: 15px; text-decoration: none;">
                &larr; Cancel and Return
            </a>

        </main>

    </body>
</html>