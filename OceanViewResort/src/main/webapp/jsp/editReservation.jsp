<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Reservation, jakarta.servlet.http.HttpSession" %>
<%
    HttpSession es = request.getSession(false);
    if (es == null || es.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Reservation r = (Reservation) request.getAttribute("reservation");
    if (r == null) { response.sendRedirect(request.getContextPath() + "/reservation?action=list"); return; }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Edit Reservation – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet"/>
</head>
<body class="bg-light">
  <%@ include file="navbar.jsp" %>

  <div class="container py-4" style="max-width:780px;">
    <div class="card border-0 shadow">
      <div class="card-header text-white fw-bold py-3" style="background:linear-gradient(135deg,#0a3d62,#1a6b8a);">
        <i class="fas fa-edit me-2"></i>Edit Reservation – <%= r.getReservationId() %>
      </div>
      <div class="card-body p-4">

        <% if (request.getAttribute("error") != null) { %>
          <div class="alert alert-danger">
            <i class="fas fa-exclamation-triangle me-2"></i><%= request.getAttribute("error") %>
          </div>
        <% } %>

        <form id="editForm" method="post"
              action="<%= ctx %>/reservation?action=edit" novalidate>

          <input type="hidden" name="action" value="edit"/>
          <input type="hidden" name="reservationId" value="<%= r.getReservationId() %>"/>

          <div class="row g-3">

            <!-- Reservation ID (read-only) -->
            <div class="col-md-6">
              <label class="form-label fw-semibold">
                <i class="fas fa-hashtag me-1 text-primary"></i>Reservation ID
              </label>
              <div class="form-control bg-light text-primary fw-bold" style="letter-spacing:2px;">
                <%= r.getReservationId() %>
              </div>
            </div>

            <!-- Room Type -->
            <div class="col-md-6">
              <label class="form-label fw-semibold" for="roomType">
                <i class="fas fa-bed me-1 text-primary"></i>Room Type *
              </label>
              <select id="roomType" name="roomType" class="form-select" required onchange="estimateCost()">
                <option value="Standard" <%= "Standard".equals(r.getRoomType()) ? "selected" : "" %>>Standard – LKR 10,000/night</option>
                <option value="Deluxe"   <%= "Deluxe".equals(r.getRoomType())   ? "selected" : "" %>>Deluxe – LKR 15,000/night</option>
                <option value="Suite"    <%= "Suite".equals(r.getRoomType())    ? "selected" : "" %>>Suite – LKR 25,000/night</option>
              </select>
            </div>

            <!-- Guest Name -->
            <div class="col-md-6">
              <label class="form-label fw-semibold" for="guestName">
                <i class="fas fa-user me-1 text-primary"></i>Guest Name *
              </label>
              <input type="text" id="guestName" name="guestName" class="form-control"
                     value="<%= r.getGuestName() %>" required minlength="2"/>
              <div class="invalid-feedback">Guest name is required.</div>
            </div>

            <!-- Contact Number -->
            <div class="col-md-6">
              <label class="form-label fw-semibold" for="contactNumber">
                <i class="fas fa-phone me-1 text-primary"></i>Contact Number *
              </label>
              <input type="text" id="contactNumber" name="contactNumber" class="form-control"
                     value="<%= r.getContactNumber() %>" required pattern="(0|\+94)[0-9]{9}"/>
              <div class="invalid-feedback">Enter valid Sri Lankan phone.</div>
            </div>

            <!-- Address -->
            <div class="col-12">
              <label class="form-label fw-semibold" for="address">
                <i class="fas fa-map-marker-alt me-1 text-primary"></i>Address *
              </label>
              <textarea id="address" name="address" class="form-control" rows="2" required><%= r.getAddress() %></textarea>
              <div class="invalid-feedback">Address is required.</div>
            </div>

            <!-- Check-in -->
            <div class="col-md-5">
              <label class="form-label fw-semibold" for="checkIn">
                <i class="fas fa-calendar-check me-1 text-primary"></i>Check-In Date *
              </label>
              <input type="date" id="checkIn" name="checkIn" class="form-control"
                     value="<%= r.getCheckIn() %>" required onchange="estimateCost()"/>
              <div class="invalid-feedback">Check-in date is required.</div>
            </div>

            <!-- Check-out -->
            <div class="col-md-5">
              <label class="form-label fw-semibold" for="checkOut">
                <i class="fas fa-calendar-times me-1 text-primary"></i>Check-Out Date *
              </label>
              <input type="date" id="checkOut" name="checkOut" class="form-control"
                     value="<%= r.getCheckOut() %>" required onchange="estimateCost()"/>
              <div class="invalid-feedback">Check-out must be after check-in.</div>
            </div>

            <!-- Cost preview -->
            <div class="col-md-2 d-flex align-items-end">
              <div class="bg-primary text-white rounded p-2 text-center w-100">
                <div class="small">Est. Cost</div>
                <div class="fw-bold" id="costPreview">—</div>
              </div>
            </div>

          </div>

          <hr class="my-4"/>
          <div class="d-flex gap-2 justify-content-end">
            <a href="<%= ctx %>/reservation?action=list" class="btn btn-outline-secondary">
              <i class="fas fa-times me-1"></i>Cancel
            </a>
            <button type="submit" class="btn btn-warning px-4 fw-bold">
              <i class="fas fa-save me-2"></i>Save Changes
            </button>
          </div>

        </form>
      </div>
    </div>
  </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
const form = document.getElementById('editForm');
form.addEventListener('submit', function(e) {
    const cin  = document.getElementById('checkIn').value;
    const cout = document.getElementById('checkOut').value;
    if (cin && cout && cout <= cin) {
        document.getElementById('checkOut').setCustomValidity('Check-out must be after check-in.');
    } else {
        document.getElementById('checkOut').setCustomValidity('');
    }
    if (!form.checkValidity()) { e.preventDefault(); e.stopPropagation(); }
    form.classList.add('was-validated');
});

function estimateCost() {
    const prices = { Standard: 10000, Deluxe: 15000, Suite: 25000 };
    const room  = document.getElementById('roomType').value;
    const cin   = document.getElementById('checkIn').value;
    const cout  = document.getElementById('checkOut').value;
    if (room && cin && cout && cout > cin) {
        const nights = (new Date(cout) - new Date(cin)) / 86400000;
        const cost   = nights * (prices[room] || 0);
        document.getElementById('costPreview').textContent =
            'LKR ' + cost.toLocaleString('en-LK', {minimumFractionDigits:2});
    } else {
        document.getElementById('costPreview').textContent = '—';
    }
}
estimateCost();
</script>
</body>
</html>
