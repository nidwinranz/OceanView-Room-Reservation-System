<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Reservation, java.util.List, java.util.ArrayList, jakarta.servlet.http.HttpSession" %>
<%
    // NOTE: variable names chosen to avoid conflict with navbar.jsp includes
    HttpSession viewSess = request.getSession(false);
    if (viewSess == null || viewSess.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    Reservation res       = (Reservation) request.getAttribute("reservation");
    String ctx            = request.getContextPath();
    String msg            = request.getParameter("msg");
    String viewRole       = (String) viewSess.getAttribute("userRole");
    boolean isAdminUser   = "ADMIN".equals(viewRole);

    // All reservations for the list
    List<Reservation> allRes = (List<Reservation>) request.getAttribute("allReservations");
    if (allRes == null) allRes = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>View Reservations – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="<%= ctx %>/css/style.css" rel="stylesheet"/>
  <style>
    .search-bar { border-radius: 12px; border: 2px solid #dee2e6; padding: 0.65rem 1rem; font-size: 0.95rem; }
    .search-bar:focus { border-color: #0a3d62; box-shadow: 0 0 0 3px rgba(10,61,98,0.12); outline: none; }
    .res-table thead th { background: linear-gradient(135deg,#0a3d62,#1a6b8a); color: #fff; font-size: 0.82rem; letter-spacing: 0.04em; text-transform: uppercase; border: none; }
    .res-table tbody tr { transition: background 0.15s; cursor: pointer; }
    .res-table tbody tr:hover { background: #e8f4fd; }
    .res-table td { vertical-align: middle; font-size: 0.88rem; }
    .badge-standard { background:#17a2b8; }
    .badge-deluxe   { background:#ffc107; color:#333; }
    .badge-suite    { background:#dc3545; }
    .detail-card { border-radius: 14px; border: 2px solid #0a3d62; }
    .detail-card .card-header { background: linear-gradient(135deg,#0a3d62,#1a6b8a); border-radius: 12px 12px 0 0; }
    .info-row { border-bottom: 1px solid #f0f0f0; padding: 0.6rem 0; }
    .info-row:last-child { border-bottom: none; }
    .stat-pill { background: #e8f4fd; border-radius: 20px; padding: 4px 14px; font-size: 0.82rem; font-weight: 600; color: #0a3d62; }
    #noResults { display: none; }
    .highlight { background: #fff3cd; border-radius: 3px; padding: 1px 2px; }
  </style>
</head>
<body class="bg-light">
  <%@ include file="navbar.jsp" %>

  <div class="container-fluid py-4 px-4" style="max-width:1300px;">

    <!-- ── Alerts ── -->
    <% if ("updated".equals(msg)) { %>
    <div class="alert alert-success alert-dismissible fade show">
      <i class="fas fa-check-circle me-2"></i><strong>Reservation updated successfully!</strong>
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>
    <% if ("deleted".equals(msg)) { %>
    <div class="alert alert-success alert-dismissible fade show">
      <i class="fas fa-check-circle me-2"></i><strong>Reservation deleted successfully.</strong>
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>
    <% if (request.getAttribute("error") != null) { %>
    <div class="alert alert-danger alert-dismissible fade show">
      <i class="fas fa-exclamation-circle me-2"></i><%= request.getAttribute("error") %>
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <div class="row g-4">

      <!-- ════════════════════════════════════════════════════════════ -->
      <!-- LEFT PANEL: Search + Reservation List                       -->
      <!-- ════════════════════════════════════════════════════════════ -->
      <div class="col-lg-7">
        <div class="card border-0 shadow-sm">
          <div class="card-header text-white py-3 d-flex justify-content-between align-items-center"
               style="background:linear-gradient(135deg,#0a3d62,#1a6b8a);">
            <span class="fw-bold">
              <i class="fas fa-list me-2"></i>All Reservations
              <span class="badge bg-white text-primary ms-2"><%= allRes.size() %></span>
            </span>
            <a href="<%= ctx %>/reservation?action=add" class="btn btn-light btn-sm">
              <i class="fas fa-plus me-1"></i>New
            </a>
          </div>
          <div class="card-body p-3">

            <!-- ── Search Bar ── -->
            <div class="row g-2 mb-3">
              <div class="col-12">
                <div class="input-group">
                  <span class="input-group-text bg-white border-end-0">
                    <i class="fas fa-search text-muted"></i>
                  </span>
                  <input type="text" id="searchBox" class="form-control border-start-0 search-bar"
                         placeholder="Search by Reservation ID, Guest Name, or NIC..."
                         oninput="filterTable()"/>
                  <button class="btn btn-outline-secondary" type="button" onclick="clearSearch()">
                    <i class="fas fa-times"></i>
                  </button>
                </div>
              </div>
              <!-- Filter by room type -->
              <div class="col-md-4">
                <select id="filterRoom" class="form-select form-select-sm" onchange="filterTable()">
                  <option value="">All Room Types</option>
                  <option value="Standard">Standard</option>
                  <option value="Deluxe">Deluxe</option>
                  <option value="Suite">Suite</option>
                </select>
              </div>
              <!-- Filter: active only -->
              <div class="col-md-4">
                <select id="filterStatus" class="form-select form-select-sm" onchange="filterTable()">
                  <option value="">All Reservations</option>
                  <option value="active">Active (future)</option>
                  <option value="past">Past</option>
                </select>
              </div>
              <!-- Result count -->
              <div class="col-md-4 d-flex align-items-center">
                <span class="stat-pill" id="resultCount">
                  Showing <span id="visibleCount"><%= allRes.size() %></span> of <%= allRes.size() %>
                </span>
              </div>
            </div>

            <!-- ── No results message ── -->
            <div id="noResults" class="text-center py-4 text-muted">
              <i class="fas fa-search fa-2x mb-2 d-block"></i>
              No reservations match your search.
            </div>

            <!-- ── Table ── -->
            <div class="table-responsive" style="max-height:520px; overflow-y:auto;">
              <table class="table table-hover res-table mb-0" id="resTable">
                <thead style="position:sticky;top:0;z-index:1;">
                  <tr>
                    <th>Res ID</th>
                    <th>Guest</th>
                    <th>NIC</th>
                    <th>Room</th>
                    <th>Check-In</th>
                    <th>Status</th>
                    <th></th>
                  </tr>
                </thead>
                <tbody>
                  <%
                    String today = java.time.LocalDate.now().toString();
                    for (Reservation r : allRes) {
                      String rType  = r.getRoomType() != null ? r.getRoomType() : "";
                      String bClass = "badge-standard";
                      if ("Deluxe".equals(rType))   bClass = "badge-deluxe";
                      else if ("Suite".equals(rType)) bClass = "badge-suite";
                      boolean isActive = r.getCheckOut() != null &&
                                         r.getCheckOut().toString().compareTo(today) >= 0;
                      String nic = r.getNationalId() != null ? r.getNationalId() : "-";
                  %>
                  <tr onclick="showDetail('<%= r.getReservationId() %>')"
                      class="res-row"
                      data-id="<%= r.getReservationId() %>"
                      data-name="<%= r.getGuestName().toLowerCase() %>"
                      data-nic="<%= nic.toLowerCase() %>"
                      data-room="<%= rType %>"
                      data-status="<%= isActive ? "active" : "past" %>"
                      data-checkout="<%= r.getCheckOut() %>">
                    <td><strong class="text-primary"><%= r.getReservationId() %></strong></td>
                    <td>
                      <% if (r.isVip()) { %><span class="text-warning me-1" title="VIP Guest">⭐</span><% } %>
                      <%= r.getGuestName() %>
                    </td>
                    <td><small class="text-muted"><%= nic %></small></td>
                    <td>
                      <span class="badge <%= bClass %>">
                        <%= rType %><% if (r.getRoomNumber() != null) { %> · <%= r.getRoomNumber() %><% } %>
                      </span>
                    </td>
                    <td><small><%= r.getCheckIn() %></small></td>
                    <td>
                      <% if (isActive) { %>
                        <span class="badge bg-success">Active</span>
                      <% } else { %>
                        <span class="badge bg-secondary">Past</span>
                      <% } %>
                    </td>
                    <td>
                      <i class="fas fa-chevron-right text-muted small"></i>
                    </td>
                  </tr>
                  <% } %>
                  <% if (allRes.isEmpty()) { %>
                  <tr><td colspan="7" class="text-center text-muted py-4">
                    <i class="fas fa-inbox fa-2x mb-2 d-block"></i>No reservations found.
                  </td></tr>
                  <% } %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <!-- ════════════════════════════════════════════════════════════ -->
      <!-- RIGHT PANEL: Reservation Detail                             -->
      <!-- ════════════════════════════════════════════════════════════ -->
      <div class="col-lg-5">

        <!-- Placeholder when nothing selected -->
        <div id="detailPlaceholder" class="card border-0 shadow-sm text-center py-5">
          <div class="text-muted">
            <i class="fas fa-mouse-pointer fa-3x mb-3 d-block" style="color:#ccc;"></i>
            <strong>Click any reservation</strong><br/>
            <small>to view full details here</small>
          </div>
        </div>

        <!-- Detail panel (hidden until row clicked) -->
        <div id="detailPanel" style="display:none;">
          <%
            // If a reservation was directly searched/passed, show it
            if (res != null) {
              String rt2   = res.getRoomType() != null ? res.getRoomType() : "";
              String badge = "bg-info";
              if ("Deluxe".equals(rt2))  badge = "bg-warning text-dark";
              if ("Suite".equals(rt2))   badge = "bg-danger";
              boolean active2 = res.getCheckOut() != null &&
                                 res.getCheckOut().toString().compareTo(today) >= 0;
          %>
          <div class="card detail-card border-0 shadow">
            <div class="card-header text-white py-3">
              <div class="d-flex justify-content-between align-items-center">
                <span class="fw-bold fs-6">
                  <i class="fas fa-file-alt me-2"></i><%= res.getReservationId() %>
                </span>
                <% if (active2) { %>
                  <span class="badge bg-success">Active</span>
                <% } else { %>
                  <span class="badge bg-secondary">Past</span>
                <% } %>
              </div>
            </div>
            <div class="card-body p-3">
              <div class="info-row d-flex justify-content-between">
                <span class="text-muted small"><i class="fas fa-user me-1"></i>Guest</span>
                <strong>
                  <% if (res.isVip()) { %><span class="text-warning me-1">⭐</span><% } %>
                  <%= res.getGuestName() %>
                </strong>
              </div>
              <div class="info-row d-flex justify-content-between">
                <span class="text-muted small"><i class="fas fa-id-card me-1"></i>NIC / Passport</span>
                <span><%= res.getNationalId() != null ? res.getNationalId() : "-" %></span>
              </div>
              <div class="info-row d-flex justify-content-between">
                <span class="text-muted small"><i class="fas fa-phone me-1"></i>Contact</span>
                <span><%= res.getContactNumber() %></span>
              </div>
              <% if (res.getEmail() != null && !res.getEmail().isEmpty()) { %>
              <div class="info-row d-flex justify-content-between">
                <span class="text-muted small"><i class="fas fa-envelope me-1"></i>Email</span>
                <span><%= res.getEmail() %></span>
              </div>
              <% } %>
              <div class="info-row d-flex justify-content-between">
                <span class="text-muted small"><i class="fas fa-map-marker-alt me-1"></i>Address</span>
                <span class="text-end" style="max-width:200px;"><%= res.getAddress() %></span>
              </div>
              <div class="info-row d-flex justify-content-between">
                <span class="text-muted small"><i class="fas fa-bed me-1"></i>Room</span>
                <span>
                  <span class="badge <%= badge %>"><%= rt2 %></span>
                  <% if (res.getRoomNumber() != null) { %>
                    &nbsp;Room <%= res.getRoomNumber() %>
                  <% } %>
                </span>
              </div>
              <div class="info-row d-flex justify-content-between">
                <span class="text-muted small"><i class="fas fa-users me-1"></i>Guests</span>
                <span><%= res.getNumAdults() %> Adult(s), <%= res.getNumChildren() %> Child(ren)</span>
              </div>
              <div class="info-row d-flex justify-content-between">
                <span class="text-muted small"><i class="fas fa-calendar-check me-1"></i>Check-In</span>
                <strong class="text-success"><%= res.getCheckIn() %></strong>
              </div>
              <div class="info-row d-flex justify-content-between">
                <span class="text-muted small"><i class="fas fa-calendar-times me-1"></i>Check-Out</span>
                <strong class="text-danger"><%= res.getCheckOut() %></strong>
              </div>
              <div class="info-row d-flex justify-content-between">
                <span class="text-muted small"><i class="fas fa-moon me-1"></i>Nights</span>
                <strong><%= res.getNights() %> night(s)</strong>
              </div>
              <% if (res.getSpecialRequests() != null && !res.getSpecialRequests().isEmpty()) { %>
              <div class="info-row d-flex justify-content-between">
                <span class="text-muted small"><i class="fas fa-concierge-bell me-1"></i>Special Requests</span>
                <span class="text-end" style="max-width:200px;"><%= res.getSpecialRequests() %></span>
              </div>
              <% } %>
              <div class="mt-3 p-3 rounded" style="background:#e8f4fd;">
                <div class="d-flex justify-content-between align-items-center">
                  <span class="fw-bold text-primary"><i class="fas fa-money-bill me-1"></i>Total Amount</span>
                  <span class="fs-5 fw-bold text-primary">LKR <%= String.format("%,.2f", res.getTotalAmount()) %></span>
                </div>
              </div>

              <!-- Action Buttons -->
              <div class="d-flex gap-2 mt-3 flex-wrap">
                <a href="<%= ctx %>/bill?id=<%= res.getReservationId() %>" class="btn btn-success btn-sm">
                  <i class="fas fa-file-invoice me-1"></i>Print Bill
                </a>
                <a href="<%= ctx %>/reservation?action=edit&id=<%= res.getReservationId() %>" class="btn btn-warning btn-sm">
                  <i class="fas fa-edit me-1"></i>Edit
                </a>
                <% if (isAdminUser) { %>
                <button class="btn btn-danger btn-sm"
                        onclick="confirmDelete('<%= res.getReservationId() %>', '<%= res.getGuestName() %>')">
                  <i class="fas fa-trash me-1"></i>Delete
                </button>
                <% } %>
              </div>
            </div>
          </div>
          <% } else { %>
          <div class="card detail-card border-0 shadow text-center py-5" id="detailEmpty">
            <i class="fas fa-mouse-pointer fa-3x mb-3 d-block" style="color:#ccc;"></i>
            <strong>Click any reservation</strong><br/>
            <small class="text-muted">to view full details</small>
          </div>
          <% } %>
        </div>

      </div>
    </div>
  </div>

  <!-- Delete Modal -->
  <div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header bg-danger text-white">
          <h5 class="modal-title"><i class="fas fa-exclamation-triangle me-2"></i>Confirm Delete</h5>
          <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          Delete reservation <strong id="delResId"></strong> for <strong id="delGuestName"></strong>?
          <br/><small class="text-danger">This cannot be undone.</small>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <a id="delConfirmBtn" href="#" class="btn btn-danger">
            <i class="fas fa-trash me-1"></i>Yes, Delete
          </a>
        </div>
      </div>
    </div>
  </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
var ctx = '<%= ctx %>';
var totalRows = <%= allRes.size() %>;

// ── Filter table by search term + room type + status ──────────────────────────
function filterTable() {
    var term       = document.getElementById('searchBox').value.toLowerCase().trim();
    var roomFilter = document.getElementById('filterRoom').value;
    var statusFilt = document.getElementById('filterStatus').value;
    var rows       = document.querySelectorAll('.res-row');
    var visible    = 0;

    rows.forEach(function(row) {
        var id     = row.getAttribute('data-id').toLowerCase();
        var name   = row.getAttribute('data-name');
        var nic    = row.getAttribute('data-nic');
        var room   = row.getAttribute('data-room');
        var status = row.getAttribute('data-status');

        var matchSearch = !term ||
            id.includes(term) || name.includes(term) || nic.includes(term);
        var matchRoom   = !roomFilter || room === roomFilter;
        var matchStatus = !statusFilt || status === statusFilt;

        if (matchSearch && matchRoom && matchStatus) {
            row.style.display = '';
            visible++;
        } else {
            row.style.display = 'none';
        }
    });

    document.getElementById('visibleCount').textContent = visible;
    document.getElementById('noResults').style.display = (visible === 0 && totalRows > 0) ? 'block' : 'none';
}

// ── Clear search ──────────────────────────────────────────────────────────────
function clearSearch() {
    document.getElementById('searchBox').value = '';
    document.getElementById('filterRoom').value = '';
    document.getElementById('filterStatus').value = '';
    filterTable();
}

// ── Click row → load detail via AJAX ─────────────────────────────────────────
function showDetail(resId) {
    // Highlight selected row
    document.querySelectorAll('.res-row').forEach(function(r) {
        r.classList.remove('table-primary');
    });
    var clicked = document.querySelector('[data-id="' + resId + '"]');
    if (clicked) clicked.classList.add('table-primary');

    // Navigate to detail (loads reservation into right panel)
    window.location.href = ctx + '/reservation?action=view&id=' + resId;
}

// ── Delete modal ──────────────────────────────────────────────────────────────
function confirmDelete(id, name) {
    document.getElementById('delResId').textContent       = id;
    document.getElementById('delGuestName').textContent   = name;
    document.getElementById('delConfirmBtn').href         =
        ctx + '/reservation?action=delete&id=' + id;
    new bootstrap.Modal(document.getElementById('deleteModal')).show();
}

// ── Show detail panel if a reservation was loaded ─────────────────────────────
<% if (res != null) { %>
document.getElementById('detailPlaceholder').style.display = 'none';
document.getElementById('detailPanel').style.display       = 'block';
// Highlight the selected row
var selectedRow = document.querySelector('[data-id="<%= res.getReservationId() %>"]');
if (selectedRow) selectedRow.classList.add('table-primary');
<% } else { %>
document.getElementById('detailPlaceholder').style.display = 'block';
document.getElementById('detailPanel').style.display       = 'none';
<% } %>
</script>
</body>
</html>
