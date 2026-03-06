<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>500 – Server Error</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
</head>
<body class="bg-light d-flex align-items-center justify-content-center" style="min-height:100vh;">
  <div class="text-center">
    <i class="fas fa-exclamation-triangle fa-5x text-danger mb-4"></i>
    <h1 class="display-1 fw-bold text-danger">500</h1>
    <h4 class="mb-3">Internal Server Error</h4>
    <p class="text-muted">Something went wrong on our end. Please try again.</p>
    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-danger mt-3">
      <i class="fas fa-home me-2"></i>Go to Dashboard
    </a>
  </div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
