<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
    <head>
        <title>RecruitX Portal - Secure Gateway</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: 'Inter', sans-serif;
            }

            body {
                height: 100vh;
                display: flex;
                background: #0f172a;
                overflow: hidden;
            }

            .left-panel {
                flex: 1.2;
                background: linear-gradient(135deg, #1e40af, #0f172a);
                color: white;
                display: flex;
                flex-direction: column;
                justify-content: center;
                padding: 60px;
                position: relative;
            }

            .left-panel h1 {
                font-size: 42px;
                font-weight: 700;
                margin-bottom: 15px;
                letter-spacing: -0.5px;
            }

            .left-panel p {
                font-size: 16px;
                opacity: 0.85;
                line-height: 1.6;
                max-width: 440px;
            }

            .badge {
                margin-top: 25px;
                display: inline-block;
                align-self: flex-start;
                padding: 8px 14px;
                background: rgba(255,255,255,0.15);
                border-radius: 20px;
                font-size: 12px;
                font-weight: 500;
            }

            .right-panel {
                flex: 1;
                display: flex;
                align-items: center;
                justify-content: center;
                background: #f1f5f9;
                padding: 20px;
            }

            .login-box {
                width: 100%;
                max-width: 400px;
                background: white;
                padding: 40px;
                border-radius: 16px;
                box-shadow: 0 20px 50px rgba(0,0,0,0.1);
            }

            .login-box h2 {
                text-align: center;
                margin-bottom: 10px;
                color: #0f172a;
                font-weight: 700;
            }

            .login-box p.subtitle {
                text-align: center;
                font-size: 14px;
                color: #64748b;
                margin-bottom: 25px;
            }

            /* ================= ROLE SELECTOR TAB SYSTEM ================= */
            .role-tabs {
                display: flex;
                background: #f1f5f9;
                padding: 4px;
                border-radius: 8px;
                margin-bottom: 24px;
            }

            .tab-btn {
                flex: 1;
                background: none;
                border: none;
                padding: 10px;
                font-size: 14px;
                font-weight: 600;
                color: #64748b;
                cursor: pointer;
                border-radius: 6px;
                transition: all 0.2s;
            }

            .tab-btn.active {
                background: white;
                color: #1e40af;
                box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            }

            .input-group {
                margin-bottom: 18px;
            }

            .input-group label {
                display: block;
                font-size: 13px;
                margin-bottom: 6px;
                color: #475569;
                font-weight: 500;
            }

            .input-group input {
                width: 100%;
                padding: 12px;
                border: 1px solid #cbd5e1;
                border-radius: 8px;
                outline: none;
                font-size: 14px;
                background-color: #fff;
                transition: 0.2s;
            }

            .input-group input:focus {
                border-color: #1e40af;
                box-shadow: 0 0 0 3px rgba(30,64,175,0.15);
            }

            .btn {
                width: 100%;
                padding: 12px;
                background: #1e40af;
                color: white;
                border: none;
                border-radius: 8px;
                font-weight: 600;
                cursor: pointer;
                font-size: 14px;
                transition: 0.2s;
            }

            .btn:hover {
                background: #1d4ed8;
            }

            .btn-success {
                background: #10b981;
            }
            .btn-success:hover {
                background: #059669;
            }

            .toggle-link {
                display: block;
                text-align: center;
                margin-top: 15px;
                font-size: 13px;
                color: #1e40af;
                text-decoration: none;
                font-weight: 500;
                cursor: pointer;
            }

            .toggle-link:hover {
                text-decoration: underline;
            }

            .footer-text {
                text-align: center;
                margin-top: 25px;
                font-size: 12px;
                color: #64748b;
                border-top: 1px solid #e2e8f0;
                padding-top: 15px;
            }

            .alert-msg {
                text-align: center;
                margin-bottom: 15px;
                font-size: 13px;
                padding: 10px;
                border-radius: 6px;
                font-weight: 500;
            }

            .error {
                background: #fee2e2;
                color: #dc2626;
            }
            .success {
                background: #dcfce7;
                color: #15803d;
            }

            @media (max-width: 900px) {
                body {
                    flex-direction: column;
                    overflow: auto;
                }
                .left-panel {
                    display: none;
                }
                .right-panel {
                    flex: 1;
                    height: 100vh;
                }
            }
        </style>
    </head>

    <body>

        <div class="left-panel">
            <h1>RecruitX Portal</h1>
            <p>
                Welcome to the Event-Driven Job Recruitment & Application Processing System[cite: 9, 10]. 
                Track job applications, process incoming resumes, and manage interview channels instantly[cite: 22].
            </p>
            <div class="badge">Candidate • Recruiter • Asynchronous Broker</div>
        </div>

        <div class="right-panel">

            <div class="login-box">

                <% if (request.getAttribute("error") != null) {%>
                <div class="alert-msg error"><%= request.getAttribute("error")%></div>
                <% } %>
                <% if (request.getAttribute("successMessage") != null) {%>
                <div class="alert-msg success"><%= request.getAttribute("successMessage")%></div>
                <% }%>

                <div id="loginFormContainer" style="display: block;">
                    <h2>Secure Gateway Login</h2>
                    <p class="subtitle">Please choose your operational role to sign in</p>

                    <div class="role-tabs">
                        <button type="button" id="tabStudent" class="tab-btn active" onclick="selectLoginRole('CANDIDATE')">Candidate</button>
                        <button type="button" id="tabStaff" class="tab-btn" onclick="selectLoginRole('RECRUITER')">Recruiter / HR Staff</button>
                    </div>

                    <form action="AuthEngine" method="post">
                        <input type="hidden" name="action" value="login" />

                        <input type="hidden" id="loginRole" name="loginRole" value="CANDIDATE" />

                        <div class="input-group">
                            <label id="usernameLabel">Candidate Matric ID / Username</label>
                            <input type="text" name="username" id="loginUsername" placeholder="e.g., s75034" required>
                        </div>

                        <div class="input-group">
                            <label>Secure Password</label>
                            <input type="password" name="password" placeholder="••••••••" required>
                        </div>

                        <button class="btn" type="submit">Sign In to RecruitX</button>
                    </form>
                    <a onclick="toggleForms(true)" class="toggle-link">Create Candidate Account</a>
                </div>

                <div id="registerFormContainer" style="display: none;">
                    <h2>Candidate Registration</h2>
                    <p class="subtitle">Join the automated recruitment ecosystem</p>
                    <form action="AuthEngine" method="post">
                        <input type="hidden" name="action" value="register" />

                        <input type="hidden" name="role" value="CANDIDATE" />

                        <div class="input-group">
                            <label>Full Name (as per ID/Passport)</label>
                            <input type="text" name="fullName" placeholder="e.g., Nur Alin Hayani" required>
                        </div>

                        <div class="input-group">
                            <label>Desired Username / Matric ID</label>
                            <input type="text" name="username" placeholder="e.g., s75034" required>
                        </div>

                        <div class="input-group">
                            <label>Account Password</label>
                            <input type="password" name="password" placeholder="••••••••" required>
                        </div>

                        <button class="btn btn-success" type="submit">Register Profile</button>
                    </form>
                    <a onclick="toggleForms(false)" class="toggle-link">Return to Login</a>
                </div>

                <div class="footer-text">
                    © 2026 RecruitX Ecosystem • All Rights Reserved
                </div>

            </div>

        </div>

        <script>
            // Handles changing labels dynamically on the Login section based on the active selection tab
            function selectLoginRole(role) {
                var candidateTab = document.getElementById("tabStudent");
                var recruiterTab = document.getElementById("tabStaff");
                var roleInput = document.getElementById("loginRole");
                var usernameLabel = document.getElementById("usernameLabel");
                var usernameInput = document.getElementById("loginUsername");

                roleInput.value = role;

                if (role === 'CANDIDATE') {
                    candidateTab.classList.add("active");
                    recruiterTab.classList.remove("active");
                    usernameLabel.innerText = "Candidate Matric ID / Username";
                    usernameInput.placeholder = "e.g., s75034";
                } else {
                    recruiterTab.classList.add("active");
                    candidateTab.classList.remove("active");
                    usernameLabel.innerText = "Recruiter System ID / Username";
                    usernameInput.placeholder = "e.g., rec_masita";
                }
            }

            // Swaps display blocks safely using absolute style directives to remove stacking defects
            function toggleForms(showRegister) {
                var loginForm = document.getElementById("loginFormContainer");
                var registerForm = document.getElementById("registerFormContainer");

                if (showRegister) {
                    loginForm.style.display = "none";
                    registerForm.style.display = "block";
                } else {
                    loginForm.style.display = "block";
                    registerForm.style.display = "none";
                }
            }
        </script>

    </body>
</html>