<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.recruitx.model.User"%>
<%
    User currUser = (User) session.getAttribute("currentUser");
    String fullName = (currUser != null) ? currUser.getFullName() : "GUEST USER";
    String roleName = (currUser != null) ? currUser.getRole() : "VISITOR";
    
    // Fetch context root path dynamically to prevent link breakage across folders
    String ctxPath = request.getContextPath();
%>

<header class="portal-header">
    <div class="header-container">
        
        <div class="brand-block">
            <div class="brand-icon">RX</div>
            <div class="brand-text">
                <h1>RECRUIT<span>X</span></h1>
                <sub>Enterprise Portal</sub>
            </div>
        </div>

        <nav class="header-navigation">
            <% 
                // ROLE CHECK: Recruiter Links
                if ("RECRUITER".equalsIgnoreCase(roleName)) { 
            %>
                <a href="<%= ctxPath %>/recruiter/recruiterDashboard.jsp" class="nav-link-item">Dashboard</a>
                <a href="<%= ctxPath %>/recruiter/candidateManagement.jsp" class="nav-link-item">Applications Management</a>
                <a href="<%= ctxPath %>/recruiter/createJob.jsp" class="nav-link-item">Issue Vacancies</a>
                <a href="<%= ctxPath %>/recruiter/scheduleInterview.jsp" class="nav-link-item">Interviews & Milestones</a>
            <% 
                // ROLE CHECK: Candidate Links (FIXED WITH nav-link-item CLASSES)
                } else if ("CANDIDATE".equalsIgnoreCase(roleName)) { 
            %>
                <a href="<%= ctxPath %>/candidate/candidatePortal.jsp" class="nav-link-item">My Profile Portal</a>
                <a href="<%= ctxPath %>/candidate/candidatePortal.jsp#vacancySection" class="nav-link-item">Explore Vacancy Board</a>
            <% 
                // FALLBACK
                } else { 
            %>
                <a href="<%= ctxPath %>/login.jsp" class="nav-link-item">Return to Login</a>
            <% } %>
        </nav>

        <div class="user-meta-block">
            
            <div class="pipeline-indicator-group">
                <div class="live-pulse-dot"></div>
                <span class="engine-terminal-badge">EDA Stream Active</span>
            </div>
            
            <div class="meta-details">
                <span class="meta-label"><%= roleName %> PIPELINE</span>
                <span class="meta-name" style="white-space: nowrap;"><%= fullName %></span>
            </div>
            
            <form action="<%= ctxPath %>/AuthEngine" method="POST" style="margin: 0; padding: 0; display: inline;">
                <input type="hidden" name="action" value="logout">
                <button type="submit" class="btn-signout" style="cursor: pointer; font-family: inherit;">
                    Sign Out
                </button>
            </form>
            
        </div>
        
    </div>
</header>

<script>
    // Automatically match current page location and apply the highlight active design token
    document.querySelectorAll('.nav-link-item').forEach(link => {
        if (window.location.href.includes(link.getAttribute('href'))) {
            link.classList.add('active');
        }
    });
</script>