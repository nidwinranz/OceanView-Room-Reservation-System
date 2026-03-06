<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Reservation, java.util.List, jakarta.servlet.http.HttpSession" %>
<%
    HttpSession ls = request.getSession(false);
    if (ls == null || ls.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    String msg = request.getParameter("msg");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>All Reservations – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet"/>
</head>
<body class="bg-light">
  <%@ include file="navbar.jsp" %>

  <div class="container py-4">
    <div class="card border-0 shadow">
      <div class="card-header text-white fw-bold py-3 d-flex justify-content-between align-items-center"
           style="background:linear-gradient(135deg,#0a3d62,#1a6b8a);">
        <span><i class="fas fa-list me-2"></i>All Reservations</span>
        <a href="<%= ctx %>/reservation?action=add" class="btn btn-light btn-sm">
          <i class="fas fa-plus me-1"></i>New Reservation
        </a>
      </div>
      <div class="card-body p-4">

        <% if ("deleted".equals(msg)) { %>
          <div class="alert alert-success"><i class="fas fa-check-circle me-2"></i>Reservation deleted successfully.</div>
        <% } %>

        <!-- Search box -->
        <div class="mb-3">
          <input type="text" id="searchBox" class="form-control" placeholder="Search by ID, guest name, room type..."/>
        </div>

        <div class="table-responsive">
          <table class="table table-hover align-middle" id="reservationTable">
            <thead class="table-dark">
              <tr>
                <th>Reservation ID</th>
                <th>Guest Name</th>
                <th>Room Type</th>
                <th>Check-In</th>
                <th>Check-Out</th>
                <th>Total (LKR)</th>
                <th class="text-center">Actions</th>
              </tr>
            </thead>
            <tbody>
              <% if (reservations != null && !reservations.isEmpty()) {
                   for (Reservation r : reservations) {
                     String badge = "secondary";
                     if ("Standard".equals(r.getRoomType())) badge = "info";
                     else if ("Deluxe".equals(r.getRoomType())) badge = "warning";
                     else if ("Suite".equals(r.getRoomType())) badge = "danger";
              %>
              <tr>
                <td><strong class="text-primary"><%= r.getReservationId() %></strong></td>
                <td><i class="fas fa-user me-1 text-muted"></i><%= r.getGuestName() %></td>
                <td><span class="badge bg-<%= badge %>"><%= r.getRoomType() %></span></td>
                <td><%= r.getCheckIn() %></td>
                <td><%= r.getCheckOut() %></td>
                <td><strong><%= String.format("%,.2f", r.getTotalAmount()) %></strong></td>
                <td class="text-center">
                  <a href="<%= ctx %>/reservation?action=view&id=<%= r.getReservationId() %>"
                     class="btn btn-sm btn-outline-primary me-1" title="View">
                    <i class="fas fa-eye"></i>
                  </a>
                  <a href="<%= ctx %>/reservation?action=edit&id=<%= r.getReservationId() %>"
                     class="btn btn-sm btn-outline-warning me-1" title="Edit">
                    <i class="fas fa-edit"></i>
                  </a>
                  <button class="btn btn-sm btn-outline-danger"
                          onclick="confirmDelete('<%= r.getReservationId() %>', '<%= r.getGuestName() %>')"
                          title="Delete">
                    <i class="fas fa-trash"></i>
                  </button>
                </td>
              </tr>
              <% } } else { %>
              <tr><td colspan="7" class="text-center text-muted py-4">No reservations found.</td></tr>
              <% } %>
            </tbody>
          </table>
        </div>

      </div>
    </div>
  </div>

  <!-- Delete Confirmation Modal -->
  <div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header bg-danger text-white">
          <h5 class="modal-title"><i class="fas fa-exclamation-triangle me-2"></i>Confirm Delete</h5>
          <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          Are you sure you want to delete reservation <strong id="deleteResId"></strong> for <strong id="deleteGuestName"></strong>? This cannot be undone.
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <a id="deleteConfirmBtn" href="#" class="btn btn-danger">
            <i class="fas fa-trash me-1"></i>Yes, Delete
          </a>
        </div>
      </div>
    </div>
  </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function confirmDelete(id, name) {
    document.getElementById('deleteResId').textContent = id;
    document.getElementById('deleteGuestName').textContent = name;
    document.getElementById('deleteConfirmBtn').href = '<%= ctx %>/reservation?action=delete&id=' + id;
    new bootstrap.Modal(document.getElementById('deleteModal')).show();
}

// Live search
document.getElementById('searchBox').addEventListener('input', function() {
    const term = this.value.toLowerCase();
    document.querySelectorAll('#reservationTable tbody tr').forEach(row => {
        row.style.display = row.textContent.toLowerCase().includes(term) ? '' : 'none';
    });
});
</script>
</body>
</html>
