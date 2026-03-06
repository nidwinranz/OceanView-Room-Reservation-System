<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="jakarta.servlet.http.HttpServletRequest" %>
<%
    HttpSession navSession = request.getSession(false);
    String loggedUser = (navSession != null && navSession.getAttribute("loggedInUser") != null)
                        ? (String) navSession.getAttribute("loggedInUser") : "Guest";
    String userRole   = (navSession != null && navSession.getAttribute("userRole") != null)
                        ? (String) navSession.getAttribute("userRole") : "";
    boolean isAdmin   = "ADMIN".equals(userRole);
%>
<nav class="navbar navbar-expand-lg navbar-dark" style="background: linear-gradient(135deg,#0a3d62,#1a6b8a);">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/dashboard">
      <i class="fas fa-umbrella-beach me-2"></i>Ocean View Resort
    </a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMenu">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navMenu">
      <ul class="navbar-nav me-auto">

        <%-- Dashboard – ALL roles --%>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/dashboard">
            <i class="fas fa-tachometer-alt me-1"></i>Dashboard
          </a>
        </li>

        <%-- New Reservation – ALL roles --%>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/reservation?action=add">
            <i class="fas fa-plus-circle me-1"></i>New Reservation
          </a>
        </li>

        <%-- View Reservation – ALL roles --%>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/reservation?action=view">
            <i class="fas fa-search me-1"></i>View Reservation
          </a>
        </li>

        <%-- Reports – ADMIN ONLY --%>
        <% if (isAdmin) { %>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/report">
            <i class="fas fa-chart-bar me-1"></i>Reports
          </a>
        </li>
        <% } %>

        <%-- Manage Staff – ADMIN ONLY --%>
        <% if (isAdmin) { %>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/staff">
            <i class="fas fa-users-cog me-1"></i>Manage Staff
          </a>
        </li>
        <% } %>

        <%-- Help – ALL roles --%>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/help">
            <i class="fas fa-question-circle me-1"></i>Help
          </a>
        </li>

      </ul>

      <%-- Right side: role badge + user dropdown --%>
      <ul class="navbar-nav ms-auto align-items-center">

        <%-- Role badge --%>
        <li class="nav-item me-2">
          <% if (isAdmin) { %>
            <span class="badge bg-warning text-dark px-3 py-2">
              <i class="fas fa-crown me-1"></i>ADMIN
            </span>
          <% } else { %>
            <span class="badge bg-info text-dark px-3 py-2">
              <i class="fas fa-user-tie me-1"></i>STAFF
            </span>
          <% } %>
        </li>

        <%-- User dropdown --%>
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
            <i class="fas fa-user-circle me-1"></i><%= loggedUser %>
          </a>
          <ul class="dropdown-menu dropdown-menu-end">
            <li><span class="dropdown-item-text text-muted small">Signed in as <strong><%= loggedUser %></strong></span></li>
            <li><hr class="dropdown-divider"/></li>
            <li>
              <a class="dropdown-item text-danger"
                 href="${pageContext.request.contextPath}/logout">
                <i class="fas fa-sign-out-alt me-2"></i>Logout
              </a>
            </li>
          </ul>
        </li>

      </ul>
    </div>
  </div>
</nav>
