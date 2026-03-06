<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Reservation, java.util.List, java.util.Map, jakarta.servlet.http.HttpSession" %>
<%
    HttpSession rs2 = request.getSession(false);
    if (rs2 == null || rs2.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Reservation> allRes    = (List<Reservation>) request.getAttribute("allReservations");
    List<Reservation> activeRes = (List<Reservation>) request.getAttribute("activeReservations");
    Map<String,Long>  byRoom    = (Map<String,Long>)  request.getAttribute("byRoomType");
    Double totalIncome          = (Double)             request.getAttribute("totalIncome");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Reports – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet"/>
</head>
<body class="bg-light">
  <%@ include file="navbar.jsp" %>

  <div class="container-fluid py-4">

    <div class="d-flex justify-content-between align-items-center mb-4">
      <h2 class="fw-bold text-primary"><i class="fas fa-chart-bar me-2"></i>Reports &amp; Analytics</h2>
      <button onclick="window.print()" class="btn btn-outline-primary">
        <i class="fas fa-print me-1"></i>Print Report
      </button>
    </div>

    <!-- Summary Cards -->
    <div class="row g-3 mb-4">
      <div class="col-md-3">
        <div class="card border-0 shadow-sm text-center p-3 h-100" style="border-top:4px solid #0a3d62!important;">
          <i class="fas fa-list fa-2x text-primary mb-2"></i>
          <div class="text-muted small">Total Reservations</div>
          <div class="fw-bold fs-2 text-primary"><%= allRes != null ? allRes.size() : 0 %></div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 shadow-sm text-center p-3 h-100" style="border-top:4px solid #27ae60!important;">
          <i class="fas fa-door-open fa-2x text-success mb-2"></i>
          <div class="text-muted small">Active Reservations</div>
          <div class="fw-bold fs-2 text-success"><%= activeRes != null ? activeRes.size() : 0 %></div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 shadow-sm text-center p-3 h-100" style="border-top:4px solid #e67e22!important;">
          <i class="fas fa-coins fa-2x text-warning mb-2"></i>
          <div class="text-muted small">Total Income</div>
          <div class="fw-bold fs-4 text-warning">LKR <%= totalIncome != null ? String.format("%,.2f",totalIncome) : "0.00" %></div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 shadow-sm text-center p-3 h-100" style="border-top:4px solid #8e44ad!important;">
          <i class="fas fa-bed fa-2x text-purple mb-2" style="color:#8e44ad"></i>
          <div class="text-muted small">Room Types Used</div>
          <div class="fw-bold fs-2" style="color:#8e44ad"><%= byRoom != null ? byRoom.size() : 0 %></div>
        </div>
      </div>
    </div>

    <div class="row g-4 mb-4">
      <!-- Reservations by Room Type -->
      <div class="col-md-6">
        <div class="card border-0 shadow-sm h-100">
          <div class="card-header fw-bold bg-primary text-white">
            <i class="fas fa-bed me-2"></i>Reservations by Room Type
          </div>
          <div class="card-body">
            <% if (byRoom != null && !byRoom.isEmpty()) {
               String[] colors = {"#17a2b8","#ffc107","#dc3545"};
               int ci = 0;
               for (Map.Entry<String,Long> e : byRoom.entrySet()) {
                   long pct = allRes != null && !allRes.isEmpty() ? e.getValue()*100/allRes.size() : 0; %>
              <div class="mb-3">
                <div class="d-flex justify-content-between mb-1">
                  <span class="fw-semibold"><%= e.getKey() %></span>
                  <span><%= e.getValue() %> reservation(s)</span>
                </div>
                <div class="progress" style="height:20px;">
                  <div class="progress-bar" style="width:<%= pct %>%;background:<%= colors[ci%3] %>;">
                    <%= pct %>%
                  </div>
                </div>
              </div>
            <% ci++; } } else { %><p class="text-muted">No data available.</p><% } %>
          </div>
        </div>
      </div>

      <!-- Active Reservations -->
      <div class="col-md-6">
        <div class="card border-0 shadow-sm h-100">
          <div class="card-header fw-bold bg-success text-white">
            <i class="fas fa-door-open me-2"></i>Active Reservations
          </div>
          <div class="card-body p-0">
            <% if (activeRes != null && !activeRes.isEmpty()) { %>
            <div class="table-responsive">
              <table class="table table-sm table-striped mb-0">
                <thead class="table-light"><tr>
                  <th>ID</th><th>Guest</th><th>Room</th><th>Check-Out</th>
                </tr></thead>
                <tbody>
                  <% for (Reservation ar : activeRes) { %>
                  <tr>
                    <td><a href="${pageContext.request.contextPath}/bill?id=<%= ar.getReservationId() %>">
                      <%= ar.getReservationId() %></a></td>
                    <td><%= ar.getGuestName() %></td>
                    <td><%= ar.getRoomType() %></td>
                    <td><%= ar.getCheckOut() %></td>
                  </tr>
                  <% } %>
                </tbody>
              </table>
            </div>
            <% } else { %><p class="text-muted p-3">No active reservations.</p><% } %>
          </div>
        </div>
      </div>
    </div>

    <!-- All Reservations Table -->
    <div class="card border-0 shadow-sm">
      <div class="card-header fw-bold bg-dark text-white">
        <i class="fas fa-table me-2"></i>All Reservations – Complete List
      </div>
      <div class="card-body p-0">
        <% if (allRes != null && !allRes.isEmpty()) { %>
        <div class="table-responsive">
          <table class="table table-striped table-hover mb-0">
            <thead class="table-dark">
              <tr>
                <th>Res. ID</th><th>Guest Name</th><th>Contact</th>
                <th>Room</th><th>Check-In</th><th>Check-Out</th>
                <th>Nights</th><th class="text-end">Amount (LKR)</th><th>Action</th>
              </tr>
            </thead>
            <tbody>
              <% for (Reservation r2 : allRes) { %>
              <tr>
                <td class="fw-bold"><%= r2.getReservationId() %></td>
                <td><%= r2.getGuestName() %></td>
                <td><%= r2.getContactNumber() %></td>
                <td><span class="badge bg-<%= "Standard".equals(r2.getRoomType())?"info":"Deluxe".equals(r2.getRoomType())?"warning":"danger" %>">
                  <%= r2.getRoomType() %></span></td>
                <td><%= r2.getCheckIn() %></td>
                <td><%= r2.getCheckOut() %></td>
                <td class="text-center"><%= r2.getNights() %></td>
                <td class="text-end fw-bold"><%= String.format("%,.2f", r2.getTotalAmount()) %></td>
                <td><a href="${pageContext.request.contextPath}/bill?id=<%= r2.getReservationId() %>"
                       class="btn btn-sm btn-outline-success">
                  <i class="fas fa-file-invoice"></i> Bill</a></td>
              </tr>
              <% } %>
            </tbody>
            <tfoot class="table-primary">
              <tr>
                <td colspan="7" class="fw-bold text-end">TOTAL INCOME:</td>
                <td class="fw-bold text-end fs-6">LKR <%= totalIncome != null ? String.format("%,.2f",totalIncome) : "0.00" %></td>
                <td></td>
              </tr>
            </tfoot>
          </table>
        </div>
        <% } else { %>
        <div class="p-4 text-center text-muted">
          <i class="fas fa-inbox fa-3x mb-3 d-block"></i>No reservations found.
        </div>
        <% } %>
      </div>
    </div>

  </div><!-- /container -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
