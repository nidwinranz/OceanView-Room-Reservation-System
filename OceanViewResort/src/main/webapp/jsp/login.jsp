<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    // Check for password reset success message
    String msg = request.getParameter("msg");
    boolean resetSuccess = "reset_success".equals(msg);
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="<%= ctx %>/css/style.css" rel="stylesheet"/>
  <style>
    body {
      background: linear-gradient(135deg,#0a3d62 0%,#1a6b8a 50%,#48b0cc 100%);
      min-height: 100vh;
      display: flex; align-items: center; justify-content: center;
      padding: 20px;
    }
    .login-card {
      background: rgba(255,255,255,0.97);
      border-radius: 16px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.3);
      overflow: hidden;
      max-width: 420px; width: 100%;
    }
    .login-header {
      background: linear-gradient(135deg,#0a3d62,#1a6b8a);
      padding: 2rem; text-align: center; color: #fff;
    }
    .login-header h3 { font-size:1.6rem; font-weight:700; margin-bottom:4px; }
    .login-header p  { font-size:0.9rem; opacity:0.85; margin:0; }
    .login-body { padding: 2rem; }
    .form-label { font-weight: 600; color: #0a3d62; }
    .btn-login {
      background: linear-gra.sdient(135deg,#0a3d62,#1a6b8a);
      color: #fff; border: none; width: 100%; padding: 0.75rem;
      border-radius: 8px; font-weight: 700; font-size: 1rem;
      transition: opacity 0.2s;
    }
    .btn-login:hover { opacity: 0.9; color: #fff; }
    .forgot-link {
      text-align: right; font-size: 0.83rem; margin-top: -8px; margin-bottom: 16px;
    }
    .forgot-link a { color: #1a6b8a; text-decoration: none; }
    .forgot-link a:hover { text-decoration: underline; }
    .default-creds {
      background: #f0f8ff; border-radius: 8px;
      padding: 0.8rem 1rem; font-size: 0.82rem; margin-top: 1rem;
    }
  </style>
</head>
<body>
<div class="login-card">

  <!-- Header -->
  <div class="login-header">
    <i class="fas fa-umbrella-beach fa-3x mb-3"></i>
    <h3>Ocean View Resort</h3>
    <p><i class="fas fa-map-marker-alt me-1"></i>Galle, Sri Lanka</p>
  </div>

  <div class="login-body">
    <h5 class="mb-4 text-center text-muted">Reservation Management System</h5>

    <!-- Password reset success alert -->
    <% if (resetSuccess) { %>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
      <i class="fas fa-check-circle me-2"></i>
      <strong>Password reset successful!</strong> You can now log in with your new password.
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <!-- Login error -->
    <% if (request.getAttribute("error") != null) { %>
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
      <i class="fas fa-exclamation-circle me-2"></i>
      <%= request.getAttribute("error") %>
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <!-- Login Form -->
    <form method="post" action="<%= ctx %>/login">
      <div class="mb-3">
        <label for="username" class="form-label">
          <i class="fas fa-user me-1"></i>Username
        </label>
        <input type="text" id="username" name="username" class="form-control form-control-lg"
               placeholder="Enter username" required autocomplete="username"/>
      </div>

      <div class="mb-1">
        <label for="password" class="form-label">
          <i class="fas fa-lock me-1"></i>Password
        </label>
        <div class="input-group">
          <input type="password" id="password" name="password" class="form-control form-control-lg"
                 placeholder="Enter password" required autocomplete="current-password"/>
          <button class="btn btn-outline-secondary" type="button"
                  onclick="togglePass()">
            <i class="fas fa-eye" id="eyeIcon"></i>
          </button>
        </div>
      </div>

      <!-- Forgot Password link -->
      <div class="forgot-link">
        <a href="<%= ctx %>/forgot-password">
          <i class="fas fa-key me-1"></i>Forgot Password?
        </a>
      </div>

      <button type="submit" class="btn btn-login">
        <i class="fas fa-sign-in-alt me-2"></i>Sign In
      </button>
    </form>

  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function togglePass() {
  const field = document.getElementById('password');
  const icon  = document.getElementById('eyeIcon');
  if (field.type === 'password') {
    field.type = 'text';
    icon.classList.replace('fa-eye', 'fa-eye-slash');
  } else {
    field.type = 'password';
    icon.classList.replace('fa-eye-slash', 'fa-eye');
  }
}
</script>
</body>
</html>
