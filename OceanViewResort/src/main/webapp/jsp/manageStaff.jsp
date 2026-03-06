<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User, java.util.List, jakarta.servlet.http.HttpSession" %>
<%
    HttpSession ms = request.getSession(false);
    if (ms == null || !"ADMIN".equals(ms.getAttribute("userRole"))) {
        response.sendRedirect(request.getContextPath() + "/access-denied"); return;
    }
    List<User> staffList = (List<User>) request.getAttribute("staffList");
    int staffCount       = request.getAttribute("staffCount") != null
                           ? (Integer) request.getAttribute("staffCount") : 0;
    String v_username    = request.getAttribute("v_username") != null
                           ? (String) request.getAttribute("v_username") : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Manage Staff – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet"/>
</head>
<body class="bg-light">
  <%@ include file="navbar.jsp" %>

  <div class="container-fluid py-4">

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h2 class="fw-bold text-primary mb-0">
          <i class="fas fa-users-cog me-2"></i>Staff Management
        </h2>
        <p class="text-muted mb-0">Register new staff and manage existing accounts</p>
      </div>
      <span class="badge bg-warning text-dark px-3 py-2 fs-6">
        <i class="fas fa-crown me-1"></i>Admin Panel
      </span>
    </div>

    <!-- Alerts -->
    <% if (request.getAttribute("error") != null) { %>
      <div class="alert alert-danger alert-dismissible fade show shadow-sm">
        <i class="fas fa-exclamation-circle me-2"></i><%= request.getAttribute("error") %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    <% } %>
    <% if (request.getAttribute("successMsg") != null) { %>
      <div class="alert alert-success alert-dismissible fade show shadow-sm">
        <i class="fas fa-check-circle me-2"></i><%= request.getAttribute("successMsg") %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    <% } %>

    <div class="row g-4">

      <!-- ── LEFT: Register New Staff Form ─────────────────────────────────── -->
      <div class="col-lg-4">
        <div class="card border-0 shadow h-100">
          <div class="card-header fw-bold text-white py-3"
               style="background:linear-gradient(135deg,#0a3d62,#1a6b8a);">
            <i class="fas fa-user-plus me-2"></i>Register New Staff Member
          </div>
          <div class="card-body p-4">
            <form id="staffForm" method="post"
                  action="${pageContext.request.contextPath}/staff?action=add"
                  novalidate>

              <!-- Username -->
              <div class="mb-3">
                <label class="form-label fw-semibold" for="username">
                  <i class="fas fa-user me-1 text-primary"></i>Username *
                </label>
                <input type="text" id="username" name="username"
                       class="form-control" placeholder="e.g. john_staff"
                       value="<%= v_username %>" required minlength="3"
                       pattern="[a-zA-Z0-9_]+"/>
                <div class="form-text">Letters, numbers and underscore only</div>
                <div class="invalid-feedback">Min 3 characters, letters/numbers/underscore only.</div>
              </div>

              <!-- Password -->
              <div class="mb-3">
                <label class="form-label fw-semibold" for="password">
                  <i class="fas fa-lock me-1 text-primary"></i>Password *
                </label>
                <div class="input-group">
                  <input type="password" id="password" name="password"
                         class="form-control" placeholder="Min 6 characters"
                         required minlength="6"/>
                  <button class="btn btn-outline-secondary" type="button"
                          onclick="togglePass('password', this)">
                    <i class="fas fa-eye"></i>
                  </button>
                </div>
                <div class="invalid-feedback">Password must be at least 6 characters.</div>
              </div>

              <!-- Confirm Password -->
              <div class="mb-4">
                <label class="form-label fw-semibold" for="confirmPassword">
                  <i class="fas fa-lock me-1 text-primary"></i>Confirm Password *
                </label>
                <div class="input-group">
                  <input type="password" id="confirmPassword" name="confirmPassword"
                         class="form-control" placeholder="Re-enter password"
                         required minlength="6"/>
                  <button class="btn btn-outline-secondary" type="button"
                          onclick="togglePass('confirmPassword', this)">
                    <i class="fas fa-eye"></i>
                  </button>
                </div>
                <div class="invalid-feedback">Passwords must match.</div>
              </div>

              <!-- Role display (always STAFF, read-only) -->
              <div class="mb-4">
                <label class="form-label fw-semibold">
                  <i class="fas fa-id-badge me-1 text-primary"></i>Role
                </label>
                <div class="form-control bg-light text-muted" style="cursor:not-allowed;">
                  <i class="fas fa-user-tie me-2 text-info"></i>STAFF (Front Desk)
                </div>
                <div class="form-text">New registrations are always given Staff role</div>
              </div>

              <button type="submit" class="btn btn-primary w-100 py-2">
                <i class="fas fa-user-plus me-2"></i>Register Staff Member
              </button>
            </form>
          </div>

          <!-- Staff permissions info -->
          <div class="card-footer bg-light">
            <p class="small fw-bold text-muted mb-2">
              <i class="fas fa-info-circle me-1 text-primary"></i>Staff Permissions:
            </p>
            <ul class="small text-muted mb-0 ps-3">
              <li>✅ Add new reservations</li>
              <li>✅ View reservation details</li>
              <li>✅ Print guest bills</li>
              <li>❌ Cannot view reports</li>
              <li>❌ Cannot manage staff</li>
              <li>❌ Cannot see income data</li>
            </ul>
          </div>
        </div>
      </div>

      <!-- ── RIGHT: Staff List ──────────────────────────────────────────────── -->
      <div class="col-lg-8">
        <div class="card border-0 shadow">
          <div class="card-header fw-bold bg-dark text-white py-3 d-flex justify-content-between align-items-center">
            <span><i class="fas fa-list me-2"></i>Current Staff Members</span>
            <span class="badge bg-info text-dark fs-6"><%= staffCount %> Staff</span>
          </div>
          <div class="card-body p-0">
            <% if (staffList != null && !staffList.isEmpty()) { %>
            <div class="table-responsive">
              <table class="table table-hover mb-0">
                <thead class="table-light">
                  <tr>
                    <th width="60">#</th>
                    <th><i class="fas fa-user me-1"></i>Username</th>
                    <th><i class="fas fa-id-badge me-1"></i>Role</th>
                    <th><i class="fas fa-key me-1"></i>Password</th>
                    <th width="120" class="text-center">Action</th>
                  </tr>
                </thead>
                <tbody>
                  <% int rowNum = 1;
                     for (User staff : staffList) { %>
                  <tr>
                    <td class="text-muted"><%= rowNum++ %></td>
                    <td>
                      <div class="d-flex align-items-center">
                        <div class="rounded-circle bg-info d-flex align-items-center justify-content-center me-2"
                             style="width:36px;height:36px;flex-shrink:0;">
                          <i class="fas fa-user text-white small"></i>
                        </div>
                        <span class="fw-semibold"><%= staff.getUsername() %></span>
                      </div>
                    </td>
                    <td>
                      <span class="badge bg-info text-dark">
                        <i class="fas fa-user-tie me-1"></i><%= staff.getRole() %>
                      </span>
                    </td>
                    <td>
                      <span class="text-muted font-monospace" id="pw_<%= staff.getId() %>">••••••••</span>
                      <button class="btn btn-sm btn-link p-0 ms-1"
                              onclick="revealPass(<%= staff.getId() %>, '<%= staff.getPassword() %>')"
                              title="Show password">
                        <i class="fas fa-eye text-muted"></i>
                      </button>
                    </td>
                    <td class="text-center">
                      <!-- Delete button with confirm -->
                      <form method="post"
                            action="${pageContext.request.contextPath}/staff?action=delete"
                            onsubmit="return confirmDelete('<%= staff.getUsername() %>')">
                        <input type="hidden" name="userId" value="<%= staff.getId() %>"/>
                        <button type="submit" class="btn btn-sm btn-outline-danger"
                                title="Remove staff member">
                          <i class="fas fa-trash-alt me-1"></i>Remove
                        </button>
                      </form>
                    </td>
                  </tr>
                  <% } %>
                </tbody>
              </table>
            </div>
            <% } else { %>
            <div class="text-center py-5 text-muted">
              <i class="fas fa-users fa-4x mb-3 d-block opacity-25"></i>
              <h5>No staff members registered yet</h5>
              <p class="small">Use the form on the left to register a new staff member.</p>
            </div>
            <% } %>
          </div>
        </div>

        <!-- Admin accounts info card -->
        <div class="card border-0 shadow-sm mt-4">
          <div class="card-header fw-bold bg-warning text-dark">
            <i class="fas fa-crown me-2"></i>Admin Accounts
          </div>
          <div class="card-body">
            <p class="text-muted small mb-0">
              <i class="fas fa-shield-alt me-1 text-warning"></i>
              Admin accounts are protected and cannot be deleted through this interface.
              There is currently <strong>1 admin account</strong> (you).
              Admin accounts have full access to all system features.
            </p>
          </div>
        </div>
      </div>

    </div><!-- /row -->
  </div><!-- /container -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// ── Form validation ───────────────────────────────────────────────────────────
const staffForm = document.getElementById('staffForm');
staffForm.addEventListener('submit', function(e) {
    const pwd  = document.getElementById('password').value;
    const cpwd = document.getElementById('confirmPassword').value;
    if (pwd !== cpwd) {
        document.getElementById('confirmPassword').setCustomValidity('Passwords do not match.');
    } else {
        document.getElementById('confirmPassword').setCustomValidity('');
    }
    if (!staffForm.checkValidity()) {
        e.preventDefault(); e.stopPropagation();
    }
    staffForm.classList.add('was-validated');
});

// ── Password visibility toggle ────────────────────────────────────────────────
function togglePass(fieldId, btn) {
    const field = document.getElementById(fieldId);
    const icon  = btn.querySelector('i');
    if (field.type === 'password') {
        field.type = 'text';
        icon.classList.replace('fa-eye', 'fa-eye-slash');
    } else {
        field.type = 'password';
        icon.classList.replace('fa-eye-slash', 'fa-eye');
    }
}

// ── Reveal stored password ────────────────────────────────────────────────────
function revealPass(id, pw) {
    const el = document.getElementById('pw_' + id);
    el.textContent = el.textContent === '••••••••' ? pw : '••••••••';
}

// ── Delete confirmation ───────────────────────────────────────────────────────
function confirmDelete(username) {
    return confirm('Are you sure you want to remove staff member "' + username + '"?\nThis action cannot be undone.');
}
</script>
</body>
</html>
