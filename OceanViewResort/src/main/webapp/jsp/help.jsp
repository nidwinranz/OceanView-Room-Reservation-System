<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession hs = request.getSession(false);
    if (hs == null || hs.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Help – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet"/>
</head>
<body class="bg-light">
  <%@ include file="navbar.jsp" %>

  <div class="container py-4" style="max-width:860px;">
    <h2 class="fw-bold text-primary mb-4"><i class="fas fa-question-circle me-2"></i>Help &amp; User Guide</h2>

    <!-- Accordion -->
    <div class="accordion" id="helpAccordion">

      <!-- 1. Login -->
      <div class="accordion-item border-0 shadow-sm mb-3 rounded">
        <h2 class="accordion-header">
          <button class="accordion-button fw-bold rounded" type="button" data-bs-toggle="collapse" data-bs-target="#h1">
            <i class="fas fa-sign-in-alt me-2 text-primary"></i>1. How to Log In
          </button>
        </h2>
        <div id="h1" class="accordion-collapse collapse show" data-bs-parent="#helpAccordion">
          <div class="accordion-body">
            <p>Navigate to the login page and enter your <strong>username</strong> and <strong>password</strong>.</p>
            <p>Default credentials: <code>admin / admin123</code> or <code>staff / staff123</code>.</p>
            <p>After successful login you will be redirected to the Dashboard.</p>
          </div>
        </div>
      </div>

      <!-- 2. Add Reservation -->
      <div class="accordion-item border-0 shadow-sm mb-3 rounded">
        <h2 class="accordion-header">
          <button class="accordion-button collapsed fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#h2">
            <i class="fas fa-plus-circle me-2 text-success"></i>2. Adding a New Reservation
          </button>
        </h2>
        <div id="h2" class="accordion-collapse collapse" data-bs-parent="#helpAccordion">
          <div class="accordion-body">
            <ol>
              <li>Click <strong>New Reservation</strong> from the navigation bar or Dashboard.</li>
              <li>Fill in all required fields:
                <ul>
                  <li><strong>Reservation ID</strong> – must be unique, format: <code>RESxxx</code> (e.g. RES007)</li>
                  <li><strong>Room Type</strong> – Standard, Deluxe, or Suite</li>
                  <li><strong>Guest Name</strong>, <strong>Contact</strong>, <strong>Address</strong></li>
                  <li><strong>Check-In</strong> and <strong>Check-Out</strong> dates</li>
                </ul>
              </li>
              <li>The estimated cost is calculated automatically as you type.</li>
              <li>Click <strong>Save Reservation</strong> to submit. You will be taken to the Bill page.</li>
            </ol>
          </div>
        </div>
      </div>

      <!-- 3. View Reservation -->
      <div class="accordion-item border-0 shadow-sm mb-3 rounded">
        <h2 class="accordion-header">
          <button class="accordion-button collapsed fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#h3">
            <i class="fas fa-search me-2 text-info"></i>3. Viewing a Reservation
          </button>
        </h2>
        <div id="h3" class="accordion-collapse collapse" data-bs-parent="#helpAccordion">
          <div class="accordion-body">
            <p>Click <strong>View Reservation</strong> in the navbar. Enter the Reservation ID (e.g. <code>RES001</code>) and press Search.
            The reservation details will appear below, along with a <em>Print Bill</em> button.</p>
          </div>
        </div>
      </div>

      <!-- 4. Bill -->
      <div class="accordion-item border-0 shadow-sm mb-3 rounded">
        <h2 class="accordion-header">
          <button class="accordion-button collapsed fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#h4">
            <i class="fas fa-file-invoice me-2 text-warning"></i>4. Printing a Bill
          </button>
        </h2>
        <div id="h4" class="accordion-collapse collapse" data-bs-parent="#helpAccordion">
          <div class="accordion-body">
            <p>From either the <em>Add Reservation</em> success page or the <em>View Reservation</em> page,
            click <strong>Print Bill</strong>. The bill includes room cost, 10% service charge, and grand total.
            Use your browser's print function or click the <strong>Print</strong> button.</p>
          </div>
        </div>
      </div>

      <!-- 5. Reports -->
      <div class="accordion-item border-0 shadow-sm mb-3 rounded">
        <h2 class="accordion-header">
          <button class="accordion-button collapsed fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#h5">
            <i class="fas fa-chart-bar me-2 text-danger"></i>5. Reports
          </button>
        </h2>
        <div id="h5" class="accordion-collapse collapse" data-bs-parent="#helpAccordion">
          <div class="accordion-body">
            <p>Click <strong>Reports</strong> in the navbar. You will find:</p>
            <ul>
              <li>Total reservation count and income summary</li>
              <li>Reservations grouped by room type with progress bars</li>
              <li>Active reservations (check-out date today or future)</li>
              <li>Complete reservations table with bill links</li>
            </ul>
          </div>
        </div>
      </div>


      <!-- 6. Logout -->
      <div class="accordion-item border-0 shadow-sm mb-3 rounded">
        <h2 class="accordion-header">
          <button class="accordion-button collapsed fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#h7">
            <i class="fas fa-sign-out-alt me-2 text-danger"></i>6. Logging Out / Exiting
          </button>
        </h2>
        <div id="h7" class="accordion-collapse collapse" data-bs-parent="#helpAccordion">
          <div class="accordion-body">
            <p>Click your username in the top-right corner of the navigation bar and select <strong>Logout</strong>.
            Your session will be terminated and you will be redirected to the login page.
            Close the browser tab to exit the system completely.</p>
          </div>
        </div>
      </div>

    </div><!-- /accordion -->

    <!-- Room Pricing Table -->
    <div class="card border-0 shadow-sm mt-4">
      <div class="card-header bg-primary text-white fw-bold">
        <i class="fas fa-bed me-2"></i>Room Pricing Reference
      </div>
      <div class="card-body p-0">
        <table class="table table-bordered mb-0">
          <thead class="table-dark"><tr><th>Room Type</th><th>Rate/Night</th><th>Description</th></tr></thead>
          <tbody>
            <tr><td>Standard</td><td>LKR 10,000</td><td>Garden view, AC, TV, en-suite bathroom</td></tr>
            <tr><td>Deluxe</td><td>LKR 15,000</td><td>Ocean view, balcony, mini-bar, Smart TV</td></tr>
            <tr><td>Suite</td><td>LKR 25,000</td><td>Luxury, Jacuzzi, butler service, lounge</td></tr>
          </tbody>
        </table>
      </div>
    </div>

    <div class="alert alert-info mt-4">
      <i class="fas fa-headset me-2"></i>
      <strong>Technical Support:</strong> Contact the IT Department at <code>it@oceanviewgalle.lk</code> or ext. 101.
    </div>
  </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
