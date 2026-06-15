<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.recruitx.model.User"%>

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
        <meta charset="UTF-8">
        <title>Create Job Posting | RecruitX</title>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/styles.css">
    </head>

    <body>

        <jsp:include page="../includes/header.jsp" />

        <main class="portal-main">
            
            <div class="section-wrapper">
                <div class="section-heading-group">
                    <h2>Create Job Posting</h2>
                </div>
                <p class="panel-description">
                    Fill out the parameters below to establish a new open vacancy. Submitting this form commits records to the database and fires an asynchronous message across the RabbitMQ cluster.
                </p>
            </div>

            <div class="form-card" style="margin: 0 auto;">
                <form action="${pageContext.request.contextPath}/RecruitmentEngine" method="post">

                    <input type="hidden" name="action" value="postJob">

                    <div class="form-group">
                        <label for="title">Job Title</label>
                        <input type="text" 
                               id="title" 
                               name="title" 
                               class="form-control" 
                               placeholder="e.g., Lead Backend Software Engineer (Java)" 
                               required>
                        <span class="form-help-text">Provide a concise, industry-standard professional designation.</span>
                    </div>

                    <div class="form-group">
                        <label for="description">Role Description</label>
                        <textarea id="description" 
                                  name="description" 
                                  class="form-control" 
                                  rows="6" 
                                  placeholder="Outline the core responsibilities, day-to-day operations, and department goals..." 
                                  required></textarea>
                    </div>

                    <div class="form-group">
                        <label for="requirements">Technical Requirements</label>
                        <textarea id="requirements" 
                                  name="requirements" 
                                  class="form-control" 
                                  rows="5" 
                                  placeholder="e.g., Spring Boot, MySQL Database Normalization, Event-Driven Architecture, RabbitMQ Integration" 
                                  required></textarea>
                        <span class="form-help-text">Separate specific stack profiles or degree expectations using commas or line breaks.</span>
                    </div>

                    <button type="submit" class="btn-broadcast" style="margin-top: 10px;">
                        Publish & Distribute via RabbitMQ
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