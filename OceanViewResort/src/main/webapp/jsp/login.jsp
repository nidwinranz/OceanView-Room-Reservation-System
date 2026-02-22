<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet"/>
  <style>
    body {
      background: linear-gradient(135deg, #0a3d62 0%, #1a6b8a 50%, #48b0cc 100%);
      min-height: 100vh;
      display: flex; align-items: center; justify-content: center;
    }
    .login-card {
      background: rgba(255,255,255,0.97);
      border-radius: 16px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.3);
      overflow: hidden;
      max-width: 420px; width: 100%;
    }
    .login-header {
      background: linear-gradient(135deg, #0a3d62, #1a6b8a);
      padding: 2rem; text-align: center; color: #fff;
    }
    .login-header h3 { font-size: 1.6rem; font-weight: 700; margin-bottom: 0.2rem; }
    .login-header p  { font-size: 0.9rem; opacity: 0.85; margin: 0; }
    .login-body { padding: 2rem; }
    .form-label { font-weight: 600; color: #0a3d62; }
    .btn-login {
      background: linear-gradient(135deg, #0a3d62, #1a6b8a);
      color: #fff; border: none; width: 100%; padding: 0.75rem;
      border-radius: 8px; font-weight: 700; font-size: 1rem;
      transition: opacity 0.2s;
    }
    .btn-login:hover { opacity: 0.9; color: #fff; }
    .wave-divider { text-align: center; color: #6c757d; font-size: 0.8rem; margin-top: 1.2rem; }
    .default-creds { background:#f0f8ff; border-radius:8px; padding:0.8rem 1rem; font-size:0.82rem; margin-top:1rem; }
  </style>
</head>
<body>
<div class="login-card">
  <div class="login-header">
    <i class="fas fa-umbrella-beach fa-3x mb-3"></i>
    <h3>Ocean View Resort</h3>
    <p><i class="fas fa-map-marker-alt"></i> Galle, Sri Lanka</p>
  </div>
  <div class="login-body">
    <h5 class="mb-4 text-center text-muted">Reservation Management System</h5>

    <% if (request.getAttribute("error") != null) { %>
      <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="fas fa-exclamation-circle me-2"></i>
        <%= request.getAttribute("error") %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/login">
      <div class="mb-3">
        <label for="username" class="form-label"><i class="fas fa-user me-1"></i>Username</label>
        <input type="text" id="username" name="username" class="form-control form-control-lg"
               placeholder="Enter username" required autocomplete="username"/>
      </div>
      <div class="mb-4">
        <label for="password" class="form-label"><i class="fas fa-lock me-1"></i>Password</label>
        <input type="password" id="password" name="password" class="form-control form-control-lg"
               placeholder="Enter password" required autocomplete="current-password"/>
      </div>
      <button type="submit" class="btn btn-login">
        <i class="fas fa-sign-in-alt me-2"></i>Sign In
      </button>
    </form>

    <div class="default-creds">
      <strong><i class="fas fa-info-circle me-1 text-primary"></i>Demo Credentials:</strong><br/>
      Admin: <code>admin</code> / <code>admin123</code> &nbsp;|&nbsp;
      Staff: <code>staff</code> / <code>staff123</code>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
