<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession ad = request.getSession(false);
    if (ad == null || ad.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    String adUser = (String) ad.getAttribute("loggedInUser");
    String adRole = (String) ad.getAttribute("userRole");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Access Denied – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet"/>
</head>
<body class="bg-light">
  <%@ include file="navbar.jsp" %>

  <div class="container py-5">
    <div class="row justify-content-center">
      <div class="col-md-6 text-center">

        <div class="card border-0 shadow-sm p-5">
          <!-- Icon -->
          <div class="mb-4">
            <div class="rounded-circle bg-danger d-inline-flex align-items-center justify-content-center"
                 style="width:100px;height:100px;">
              <i class="fas fa-lock fa-3x text-white"></i>
            </div>
          </div>

          <h2 class="fw-bold text-danger mb-2">Access Denied</h2>
          <h5 class="text-muted mb-4">You don't have permission to view this page</h5>

          <!-- User info -->
          <div class="alert alert-warning mb-4">
            <i class="fas fa-user-tie me-2"></i>
            You are logged in as <strong><%= adUser %></strong>
            with <strong><%= adRole %></strong> role.
            <br/>
            <small class="text-muted">This page requires <strong>ADMIN</strong> access.</small>
          </div>

          <!-- What staff CAN do -->
          <div class="text-start bg-light rounded p-3 mb-4">
            <p class="fw-bold small mb-2">
              <i class="fas fa-check-circle text-success me-1"></i>As a Staff member, you can:
            </p>
            <ul class="small text-muted mb-0">
              <li>Add new guest reservations</li>
              <li>View and search reservations</li>
              <li>Print guest bills</li>
            </ul>
          </div>

          <!-- Action buttons -->
          <div class="d-flex gap-2 justify-content-center">
            <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary px-4">
              <i class="fas fa-home me-2"></i>Go to Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/reservation?action=add" class="btn btn-outline-success px-4">
              <i class="fas fa-plus me-2"></i>New Reservation
            </a>
          </div>
        </div>

      </div>
    </div>
  </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
