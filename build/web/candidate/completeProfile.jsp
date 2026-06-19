<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.recruitx.model.User" %>
<%
    // Secure session context validation matching your 'currentUser' attribute key
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
        <title>Complete Profile | RecruitX</title>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/styles.css">

        <style>
            .profile-setup-box {
                max-width: 600px;
                margin: 40px auto;
                padding: 35px;
                background: #ffffff;
                border-radius: 8px;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            }
            .form-field-group {
                margin-bottom: 22px;
                display: flex;
                flex-direction: column;
            }
            .form-field-group label {
                font-size: 0.8rem;
                font-weight: 700;
                color: var(--primary, #0f172a);
                margin-bottom: 8px;
                text-transform: uppercase;
                letter-spacing: 0.5px;
            }
            .form-input-control {
                padding: 12px 14px;
                border: 1px solid #cbd5e1;
                border-radius: 4px;
                font-size: 0.95rem;
                color: var(--text-dark, #334155);
                outline: none;
                transition: border-color 0.2s ease;
            }
            .form-input-control:focus {
                border-color: var(--accent, #ff6b00);
            }
            .pdf-upload-container {
                border: 2px dashed #cbd5e1;
                padding: 25px;
                text-align: center;
                border-radius: 6px;
                background: #f8fafc;
                margin-top: 5px;
            }
            .pdf-upload-container input[type="file"] {
                font-size: 0.9rem;
                color: #475569;
            }
            .btn-profile-submit {
                background: var(--accent, #ff6b00);
                color: #ffffff;
                border: none;
                padding: 14px;
                border-radius: 4px;
                font-weight: 700;
                width: 100%;
                cursor: pointer;
                margin-top: 15px;
                font-size: 1rem;
                transition: background 0.2s ease;
            }
            .btn-profile-submit:hover {
                background: #e05e00;
            }
            .error-message-banner {
                background-color: #fef2f2;
                color: #991b1b;
                padding: 12px;
                border-radius: 4px;
                margin-bottom: 20px;
                font-size: 0.88rem;
                font-weight: 600;
                border-left: 4px solid #ef4444;
            }
        </style>
    </head>
    <body>

        <jsp:include page="../includes/header.jsp" />

        <div class="portal-main">
            <div class="profile-setup-box">
                <h2 style="color: var(--primary); margin-bottom: 6px;">Setup Your Candidate Profile</h2>
                <p style="color: #64748b; font-size: 0.9rem; margin-bottom: 25px;">
                    Please finalize your profile details to unlock live tracking applications inside the EDA telemetry broker engine.
                </p>

                <% if (request.getAttribute("error") != null) {%>
                <div class="error-message-banner">
                    ❌ <%= request.getAttribute("error")%>
                </div>
                <% }%>

                <form action="${pageContext.request.contextPath}/AuthEngine" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="updateProfile">

                    <div class="form-field-group">
                        <label for="fullName">Full Name</label>
                        <input type="text" id="fullName" name="fullName" class="form-input-control" 
                               value="<%= user.getFullName() != null ? user.getFullName() : ""%>" required>
                    </div>

                    <div class="form-field-group">
                        <label>Account ID / Registered Email Reference</label>
                        <input type="text" class="form-input-control" style="background-color: #f1f5f9; cursor: not-allowed;" 
                               value="<%= user.getEmail() != null ? user.getEmail() : "No email mapped"%>" readonly>
                    </div>

                    <div class="form-field-group">
                        <label for="phone">Phone Number</label>

                        <input type="text"
                               id="phone"
                               name="phone"
                               class="form-input-control"
                               value="<%= user.getPhone() != null ? user.getPhone() : ""%>"
                               placeholder="e.g. 0123456789"
                               required>
                    </div>

                    <div class="form-field-group">
                        <label for="address">Address</label>

                        <textarea id="address"
                                  name="address"
                                  class="form-input-control"
                                  rows="3"
                                  placeholder="Enter your address"
                                  required><%= user.getAddress() != null ? user.getAddress() : ""%></textarea>
                    </div>

                    <div class="form-field-group">
                        <label>Curriculum Vitae Repository (PDF Mode Only)</label>
                        <div class="pdf-upload-container">
                            <input type="file"
                                   name="resumePdf"
                                   accept=".pdf"
                                   <%= user.getResumePath() == null ? "required" : ""%>>
                            <% if (user.getResumePath() != null) {%>
                            <p style="margin-top:10px; color:green; font-size:0.85rem;">
                                Current Resume:
                                <strong><%= user.getResumePath()%></strong>
                            </p>
                            <% }%>
                            <p style="font-size: 0.78rem; color: #64748b; margin-top: 10px; margin-bottom: 0;">
                                Note: Only <b>.pdf</b> standard documents are accepted. Files will be mapped uniquely matching your candidate credentials.
                            </p>
                        </div>
                    </div>

                    <button type="submit" class="btn-profile-submit">Save Details & Complete Mapping</button>

                    <div style="text-align: center; margin-top: 15px;">
                        <a href="candidatePortal.jsp" style="color: #64748b; font-size: 0.88rem; text-decoration: none;">Cancel & Return to Board</a>
                    </div>
                </form>
            </div>
        </div>

    </body>
</html>