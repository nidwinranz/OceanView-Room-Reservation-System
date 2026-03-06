<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Reservation, jakarta.servlet.http.HttpSession" %>
<%
    HttpSession bs = request.getSession(false);
    if (bs == null || bs.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Reservation r = (Reservation) request.getAttribute("reservation");
    if (r == null) { response.sendRedirect(request.getContextPath() + "/reservation?action=view"); return; }

    double pricePerNight = r.getTotalAmount() / r.getNights();
    double tax   = r.getTotalAmount() * 0.10;
    double grand = r.getTotalAmount() + tax;
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Bill – <%= r.getReservationId() %> – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet"/>
  <style>
    @media print {
      .no-print { display: none !important; }
      body { margin: 0; background: #fff; }
      .bill-container { box-shadow: none !important; border: 1px solid #ccc; }
    }
    .bill-container { max-width: 680px; margin: 0 auto; }
    .bill-header { background: linear-gradient(135deg,#0a3d62,#1a6b8a); color:#fff; padding:2rem; text-align:center; }
    .bill-header h4 { font-weight:800; letter-spacing:1px; }
    .bill-meta td { padding: 0.35rem 0.8rem; font-size:0.93rem; }
    .amount-row td { font-size: 1.05rem; }
    .grand-total { background:#e8f4f8; font-size:1.3rem; font-weight:800; }
    .vip-badge { background:#ffd700; color:#333; border-radius:20px; padding:2px 10px; font-size:0.8rem; font-weight:700; }
    .section-title { font-weight:700; font-size:0.95rem; border-bottom:1px solid #dee2e6; padding-bottom:6px; margin-bottom:10px; }
  </style>
</head>
<body class="bg-light py-4">
  <div class="no-print mb-3 container" style="max-width:680px;">
    <%@ include file="navbar.jsp" %>
  </div>

  <div class="bill-container card border-0 shadow">

    <!-- Header -->
    <div class="bill-header">
      <i class="fas fa-umbrella-beach fa-2x mb-2"></i>
      <h4>OCEAN VIEW RESORT</h4>
      <div>Unawatuna Road, Galle 80000, Sri Lanka</div>
      <div class="mt-1">
        <i class="fas fa-phone me-1"></i>+94 91 222 3456 &nbsp;
        <i class="fas fa-envelope me-1"></i>info@oceanviewgalle.lk
      </div>
    </div>

    <div class="card-body p-4">

      <!-- Bill title + reservation ID -->
      <div class="d-flex justify-content-between align-items-start mb-4">
        <div>
          <h5 class="fw-bold text-primary mb-0">ROOM RESERVATION BILL</h5>
          <div class="text-muted small">Official Receipt</div>
        </div>
        <div class="text-end">
          <span class="badge bg-primary fs-6 px-3 py-2"><%= r.getReservationId() %></span>
          <% if (r.isVip()) { %>
            <br/><span class="vip-badge mt-1 d-inline-block">⭐ VIP Guest</span>
          <% } %>
          <div class="text-muted small mt-1">Date: <%= java.time.LocalDate.now() %></div>
        </div>
      </div>

      <!-- Guest Information -->
      <div class="bg-light rounded p-3 mb-3">
        <div class="section-title"><i class="fas fa-user me-2 text-primary"></i>Guest Information</div>
        <table class="table table-sm table-borderless mb-0 bill-meta">
          <tr>
            <td class="text-muted" width="35%">Guest Name</td>
            <td class="fw-semibold">
              <%= r.getGuestName() %>
              <% if (r.isVip()) { %><span class="vip-badge ms-2">⭐ VIP</span><% } %>
            </td>
          </tr>
          <% if (r.getNationalId() != null && !r.getNationalId().isEmpty()) { %>
          <tr>
            <td class="text-muted">National ID / Passport</td>
            <td><%= r.getNationalId() %></td>
          </tr>
          <% } %>
          <tr>
            <td class="text-muted">Contact Number</td>
            <td><%= r.getContactNumber() %></td>
          </tr>
          <% if (r.getEmail() != null && !r.getEmail().isEmpty()) { %>
          <tr>
            <td class="text-muted">Email</td>
            <td><%= r.getEmail() %></td>
          </tr>
          <% } %>
          <tr>
            <td class="text-muted">Address</td>
            <td><%= r.getAddress() %></td>
          </tr>
          <tr>
            <td class="text-muted">No. of Guests</td>
            <td>
              <%= r.getNumAdults() %> Adult<%= r.getNumAdults() != 1 ? "s" : "" %>
              <% if (r.getNumChildren() > 0) { %>
                , <%= r.getNumChildren() %> Child<%= r.getNumChildren() != 1 ? "ren" : "" %>
              <% } %>
            </td>
          </tr>
        </table>
      </div>

      <!-- Stay Details -->
      <div class="bg-light rounded p-3 mb-3">
        <div class="section-title"><i class="fas fa-bed me-2 text-primary"></i>Stay Details</div>
        <table class="table table-sm table-borderless mb-0 bill-meta">
          <tr>
            <td class="text-muted" width="35%">Room Type</td>
            <td class="fw-semibold"><%= r.getRoomType() %></td>
          </tr>
          <% if (r.getRoomNumber() != null && !r.getRoomNumber().isEmpty()) { %>
          <tr>
            <td class="text-muted">Room Number</td>
            <td class="fw-semibold">Room <%= r.getRoomNumber() %></td>
          </tr>
          <% } %>
          <tr>
            <td class="text-muted">Check-In</td>
            <td><i class="fas fa-calendar-check text-success me-1"></i><%= r.getCheckIn() %></td>
          </tr>
          <tr>
            <td class="text-muted">Check-Out</td>
            <td><i class="fas fa-calendar-times text-danger me-1"></i><%= r.getCheckOut() %></td>
          </tr>
          <tr>
            <td class="text-muted">Duration</td>
            <td><strong><%= r.getNights() %></strong> night(s)</td>
          </tr>
        </table>
      </div>

      <!-- Special Requests -->
      <% if (r.getSpecialRequests() != null && !r.getSpecialRequests().isEmpty()) { %>
      <div class="bg-light rounded p-3 mb-3">
        <div class="section-title"><i class="fas fa-concierge-bell me-2 text-primary"></i>Special Requests</div>
        <p class="mb-0 small"><%= r.getSpecialRequests() %></p>
      </div>
      <% } %>

      <!-- Bill Breakdown -->
      <div class="section-title mt-3"><i class="fas fa-calculator me-2 text-primary"></i>Bill Breakdown</div>
      <table class="table table-bordered amount-row">
        <thead class="table-dark">
          <tr>
            <th>Description</th>
            <th class="text-end">Amount (LKR)</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>
              <%= r.getRoomType() %> Room
              <% if (r.getRoomNumber() != null && !r.getRoomNumber().isEmpty()) { %>
                (Room <%= r.getRoomNumber() %>)
              <% } %>
              × <%= r.getNights() %> night(s)
              @ LKR <%= String.format("%,.2f", pricePerNight) %>/night
            </td>
            <td class="text-end"><%= String.format("%,.2f", r.getTotalAmount()) %></td>
          </tr>
          <tr>
            <td>Service Charge (10%)</td>
            <td class="text-end"><%= String.format("%,.2f", tax) %></td>
          </tr>
        </tbody>
        <tfoot>
          <tr class="grand-total">
            <td class="text-primary"><i class="fas fa-money-bill me-2"></i>TOTAL PAYABLE</td>
            <td class="text-end text-primary">LKR <%= String.format("%,.2f", grand) %></td>
          </tr>
        </tfoot>
      </table>

      <div class="text-center text-muted mt-3 small">
        <i class="fas fa-heart text-danger me-1"></i>
        Thank you for choosing Ocean View Resort, Galle. We look forward to welcoming you!
      </div>
    </div>

    <!-- Footer -->
    <div class="card-footer bg-primary text-white text-center py-2 small">
      This is a computer-generated bill. No signature required.
    </div>
  </div>

  <!-- Action Buttons -->
  <div class="d-flex justify-content-center gap-2 mt-4 no-print" style="max-width:680px;margin:auto;">
    <button onclick="window.print()" class="btn btn-primary">
      <i class="fas fa-print me-1"></i>Print Bill
    </button>
    <a href="${pageContext.request.contextPath}/reservation?action=view&id=<%= r.getReservationId() %>"
       class="btn btn-outline-secondary">
      <i class="fas fa-arrow-left me-1"></i>Back
    </a>
    <a href="${pageContext.request.contextPath}/reservation?action=add" class="btn btn-success">
      <i class="fas fa-plus me-1"></i>New Reservation
    </a>
  </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
