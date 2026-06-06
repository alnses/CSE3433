<%@page pageEncoding="UTF-8"%>
<%@page import="com.recruitx.model.User"%>
<%
    User currUser = (User) session.getAttribute("currentUser");
    String badgeTitle = (currUser != null) ? currUser.getRole() + " | " + currUser.getFullName() : "GUEST";
%>
<div class="navbar">
    <div class="navbar-brand">
        <h2>RECRUITX SYSTEM PORTAL</h2>
    </div>
    <div class="navbar-user-info">
        <span class="user-badge"><%= badgeTitle %></span>
        <a href="${pageContext.request.contextPath}/AuthEngine" class="header-logout">Sign Out</a>
    </div>
</div>