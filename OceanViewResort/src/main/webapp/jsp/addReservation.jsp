<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession as = request.getSession(false);
    if (as == null || as.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    String ctx        = request.getContextPath();
    String nextResId  = request.getAttribute("nextResId")     != null ? (String)request.getAttribute("nextResId")     : "";
    String v_name     = request.getAttribute("v_name")        != null ? (String)request.getAttribute("v_name")        : "";
    String v_address  = request.getAttribute("v_address")     != null ? (String)request.getAttribute("v_address")     : "";
    String v_phone    = request.getAttribute("v_phone")       != null ? (String)request.getAttribute("v_phone")       : "";
    String v_email    = request.getAttribute("v_email")       != null ? (String)request.getAttribute("v_email")       : "";
    String v_natId    = request.getAttribute("v_nationalId")  != null ? (String)request.getAttribute("v_nationalId")  : "";
    String v_adults   = request.getAttribute("v_numAdults")   != null ? (String)request.getAttribute("v_numAdults")   : "1";
    String v_children = request.getAttribute("v_numChildren") != null ? (String)request.getAttribute("v_numChildren") : "0";
    String v_specReqs = request.getAttribute("v_specialReqs") != null ? (String)request.getAttribute("v_specialReqs") : "";
    String v_room     = request.getAttribute("v_room")        != null ? (String)request.getAttribute("v_room")        : "";
    String v_roomNum  = request.getAttribute("v_roomNumber")  != null ? (String)request.getAttribute("v_roomNumber")  : "";
    String v_in       = request.getAttribute("v_in")          != null ? (String)request.getAttribute("v_in")          : "";
    String v_out      = request.getAttribute("v_out")         != null ? (String)request.getAttribute("v_out")         : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <title>Add Reservation – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="${pageContext.request.contextPath}/css/style.css" rel="stylesheet"/>
  <style>
    .vip-badge { background:#ffd700; color:#333; border-radius:20px; padding:3px 12px; font-size:0.8rem; font-weight:700; }
    .returning-alert { background:#d4edda; border:1px solid #28a745; border-radius:8px; padding:10px 14px; margin-bottom:12px; display:none; }
    .room-btn { border:2px solid #dee2e6; border-radius:8px; padding:8px 14px; cursor:pointer; transition:all 0.2s; background:#fff; }
    .room-btn:hover { border-color:#0a3d62; background:#e8f4fd; }
    .room-btn.selected { border-color:#0a3d62; background:#0a3d62; color:#fff; }
    .room-btn.unavailable { border-color:#dc3545; background:#f8d7da; color:#721c24; cursor:not-allowed; opacity:0.6; }
  </style>
</head>
<body class="bg-light">
  <%@ include file="navbar.jsp" %>

  <div class="container py-4" style="max-width:820px;">
    <div class="card border-0 shadow">
      <div class="card-header text-white fw-bold py-3" style="background:linear-gradient(135deg,#0a3d62,#1a6b8a);">
        <i class="fas fa-plus-circle me-2"></i>New Room Reservation
      </div>
      <div class="card-body p-4">

        <% if (request.getAttribute("error") != null) { %>
          <div class="alert alert-danger">
            <i class="fas fa-exclamation-triangle me-2"></i><%= request.getAttribute("error") %>
          </div>
        <% } %>

        <!-- Returning guest notice -->
        <div class="returning-alert" id="returningAlert">
          <i class="fas fa-star text-warning me-2"></i>
          <strong>Returning Guest detected!</strong> Details have been auto-filled.
          <span id="vipNotice"></span>
        </div>

        <form id="reservationForm" method="post"
              action="<%= ctx %>/reservation?action=add" novalidate>

          <input type="hidden" name="reservationId" value="<%= nextResId %>"/>

          <!-- ── SECTION 1: Reservation Info ── -->
          <h6 class="fw-bold text-primary mb-3 border-bottom pb-2">
            <i class="fas fa-info-circle me-1"></i>Reservation Info
          </h6>
          <div class="row g-3 mb-4">

            <!-- Reservation ID -->
            <div class="col-md-6">
              <label class="form-label fw-semibold">
                <i class="fas fa-hashtag me-1 text-primary"></i>Reservation ID
              </label>
              <div class="form-control bg-light text-primary fw-bold" style="letter-spacing:2px;"><%= nextResId %></div>
              <div class="form-text">Auto-generated</div>
            </div>

            <!-- Room Type -->
            <div class="col-md-6">
              <label class="form-label fw-semibold" for="roomType">
                <i class="fas fa-bed me-1 text-primary"></i>Room Type *
              </label>
              <select id="roomType" name="roomType" class="form-select" required onchange="loadAvailableRooms()">
                <option value="">-- Select Room Type --</option>
                <option value="Standard" <%= "Standard".equals(v_room) ? "selected" : "" %>>Standard – LKR 10,000/night</option>
                <option value="Deluxe"   <%= "Deluxe".equals(v_room)   ? "selected" : "" %>>Deluxe – LKR 15,000/night</option>
                <option value="Suite"    <%= "Suite".equals(v_room)    ? "selected" : "" %>>Suite – LKR 25,000/night</option>
              </select>
              <div class="invalid-feedback">Please select a room type.</div>
            </div>

            <!-- Check-in -->
            <div class="col-md-5">
              <label class="form-label fw-semibold" for="checkIn">
                <i class="fas fa-calendar-check me-1 text-primary"></i>Check-In Date *
              </label>
              <input type="date" id="checkIn" name="checkIn" class="form-control"
                     value="<%= v_in %>" required onchange="updateCheckoutMin(); loadAvailableRooms();"/>
              <div class="invalid-feedback">Check-in date cannot be in the past.</div>
            </div>

            <!-- Check-out -->
            <div class="col-md-5">
              <label class="form-label fw-semibold" for="checkOut">
                <i class="fas fa-calendar-times me-1 text-primary"></i>Check-Out Date *
              </label>
              <input type="date" id="checkOut" name="checkOut" class="form-control"
                     value="<%= v_out %>" required onchange="loadAvailableRooms();"/>
              <div class="invalid-feedback">Check-out must be at least 1 night after check-in.</div>
            </div>

            <!-- Cost preview -->
            <div class="col-md-2 d-flex align-items-end">
              <div class="bg-primary text-white rounded p-2 text-center w-100">
                <div class="small">Est. Cost</div>
                <div class="fw-bold" id="costPreview">—</div>
              </div>
            </div>

            <!-- Room Number selection -->
            <div class="col-12">
              <label class="form-label fw-semibold">
                <i class="fas fa-door-open me-1 text-primary"></i>Room Number *
              </label>
              <input type="hidden" name="roomNumber" id="roomNumber" value="<%= v_roomNum %>"/>
              <div id="roomButtons" class="d-flex flex-wrap gap-2">
                <span class="text-muted small">Select room type and dates to see available rooms</span>
              </div>
              <div class="invalid-feedback d-block" id="roomNumberError" style="display:none!important;"></div>
            </div>

          </div>

          <!-- ── SECTION 2: Guest Info ── -->
          <h6 class="fw-bold text-primary mb-3 border-bottom pb-2">
            <i class="fas fa-user me-1"></i>Guest Information
          </h6>
          <div class="row g-3 mb-4">

            <!-- National ID / Passport — triggers auto-fill -->
            <div class="col-md-6">
              <label class="form-label fw-semibold" for="nationalId">
                <i class="fas fa-id-card me-1 text-primary"></i>National ID / Passport *
              </label>
              <div class="input-group">
                <input type="text" id="nationalId" name="nationalId" class="form-control"
                       placeholder="e.g. 200012345678 or 991234567V"
                       value="<%= v_natId %>" required
                       maxlength="20"
                       oninput="this.value=this.value.replace(/[^0-9VvXx]/g,'').substring(0,20); lookupGuest(this.value); this.setCustomValidity('');"/>
                <span class="input-group-text" id="lookupSpinner" style="display:none;">
                  <i class="fas fa-spinner fa-spin"></i>
                </span>
              </div>
              <div class="form-text">Enter ID to auto-fill returning guest details</div>
              <div class="invalid-feedback">National ID / Passport is required.</div>
            </div>

            <!-- Guest Name -->
            <div class="col-md-6">
              <label class="form-label fw-semibold" for="guestName">
                <i class="fas fa-user me-1 text-primary"></i>Guest Name *
                <span id="vipBadge" class="vip-badge ms-2" style="display:none;">⭐ VIP</span>
              </label>
              <input type="text" id="guestName" name="guestName" class="form-control"
                     placeholder="Full name (letters only)"
                     value="<%= v_name %>" required minlength="2" pattern="[A-Za-z\s]+"
                     oninput="this.value=this.value.replace(/[^A-Za-z\s]/g,''); this.setCustomValidity('');"/>
              <div class="invalid-feedback">Guest name must contain letters only.</div>
            </div>

            <!-- Email -->
            <div class="col-md-6">
              <label class="form-label fw-semibold" for="email">
                <i class="fas fa-envelope me-1 text-primary"></i>Email Address
              </label>
              <input type="email" id="email" name="email" class="form-control"
                     placeholder="guest@example.com" value="<%= v_email %>"/>
              <div class="form-text">Optional — for booking confirmation</div>
              <div class="invalid-feedback">Please enter a valid email address.</div>
            </div>

            <!-- Contact Number -->
            <div class="col-md-6">
              <label class="form-label fw-semibold" for="contactNumber">
                <i class="fas fa-phone me-1 text-primary"></i>Contact Number *
              </label>
              <input type="text" id="contactNumber" name="contactNumber" class="form-control"
                     placeholder="e.g. 0711234567 or +94711234567"
                     value="<%= v_phone %>" required
                     maxlength="15"
                     oninput="this.value=this.value.replace(/[^0-9+]/g,'').substring(0,15); this.setCustomValidity('');"/>
              <div class="form-text">
                Numbers only &nbsp;·&nbsp; Max 15 digits &nbsp;·&nbsp;
                Local: <code>07XXXXXXXX</code> &nbsp;|&nbsp; Intl: <code>+94XXXXXXXXX</code>
              </div>
              <div class="invalid-feedback">Enter a valid phone number (numbers only, max 15 digits).</div>
            </div>

            <!-- Address -->
            <div class="col-12">
              <label class="form-label fw-semibold" for="address">
                <i class="fas fa-map-marker-alt me-1 text-primary"></i>Address *
              </label>
              <textarea id="address" name="address" class="form-control" rows="2"
                        placeholder="Guest's home address" required><%= v_address %></textarea>
              <div class="invalid-feedback">Address is required.</div>
            </div>

            <!-- Number of Guests -->
            <div class="col-md-3">
              <label class="form-label fw-semibold" for="numAdults">
                <i class="fas fa-users me-1 text-primary"></i>Adults *
              </label>
              <input type="number" id="numAdults" name="numAdults" class="form-control"
                     min="1" max="10" value="<%= v_adults %>" required/>
              <div class="invalid-feedback">At least 1 adult required.</div>
            </div>

            <div class="col-md-3">
              <label class="form-label fw-semibold" for="numChildren">
                <i class="fas fa-child me-1 text-primary"></i>Children
              </label>
              <input type="number" id="numChildren" name="numChildren" class="form-control"
                     min="0" max="10" value="<%= v_children %>"/>
            </div>

            <!-- Special Requests -->
            <div class="col-12">
              <label class="form-label fw-semibold" for="specialRequests">
                <i class="fas fa-concierge-bell me-1 text-primary"></i>Special Requests
              </label>
              <textarea id="specialRequests" name="specialRequests" class="form-control" rows="2"
                        placeholder="e.g. Early check-in, extra bed, dietary requirements..."><%= v_specReqs %></textarea>
              <div class="form-text">Optional — we'll do our best to accommodate</div>
            </div>

          </div>

          <hr class="my-3"/>
          <div class="d-flex gap-2 justify-content-end">
            <a href="<%= ctx %>/dashboard" class="btn btn-outline-secondary">
              <i class="fas fa-times me-1"></i>Cancel
            </a>
            <button type="submit" class="btn btn-primary px-4">
              <i class="fas fa-save me-2"></i>Save Reservation
            </button>
          </div>

        </form>
      </div>
    </div>
  </div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
const ctx  = '<%= ctx %>';
const today = new Date().toISOString().split('T')[0];
document.getElementById('checkIn').min = today;

// ── Form validation ───────────────────────────────────────────────────────────
const form = document.getElementById('reservationForm');
form.addEventListener('submit', function(e) {

    // Guest name
    var gname = document.getElementById('guestName');
    if (!/^[A-Za-z\s]+$/.test(gname.value.trim()))
        gname.setCustomValidity('Guest name must contain letters only.');
    else gname.setCustomValidity('');

    // NIC / Passport - alphanumeric only (no special characters)
    var nic = document.getElementById('nationalId');
    var nicVal = nic.value.trim();
    if (nicVal.length < 5) {
        nic.setCustomValidity('NIC / Passport must be at least 5 characters.');
    } else if (!/^[0-9A-Za-z]+$/.test(nicVal)) {
        nic.setCustomValidity('NIC / Passport must contain numbers and letters only (no spaces or symbols).');
    } else {
        nic.setCustomValidity('');
    }

    // Phone - numbers only, 7-15 digits (+ allowed at start)
    var phone = document.getElementById('contactNumber');
    var phoneVal = phone.value.trim();
    if (!/^[+]?[0-9]{7,15}$/.test(phoneVal)) {
        phone.setCustomValidity('Enter a valid phone number (numbers only, 7–15 digits).');
    } else {
        phone.setCustomValidity('');
    }

    // Email (optional)
    const email = document.getElementById('email');
    if (email.value.trim() && !/^[\w._%+\-]+@[\w.\-]+\.[a-zA-Z]{2,}$/.test(email.value.trim()))
        email.setCustomValidity('Enter a valid email address.');
    else email.setCustomValidity('');

    // Check-in not in past
    const cin = document.getElementById('checkIn');
    if (cin.value < today) cin.setCustomValidity('Check-in cannot be in the past.');
    else cin.setCustomValidity('');

    // Check-out at least 1 night
    const cout = document.getElementById('checkOut');
    if (cin.value && cout.value) {
        const nights = (new Date(cout.value) - new Date(cin.value)) / 86400000;
        if (nights < 1) cout.setCustomValidity('Check-out must be at least 1 night after check-in.');
        else cout.setCustomValidity('');
    }

    // Room number selected
    if (!document.getElementById('roomNumber').value) {
        document.getElementById('roomNumberError').textContent = 'Please select a room number.';
        document.getElementById('roomNumberError').style.display = 'block';
        e.preventDefault(); e.stopPropagation();
    } else {
        document.getElementById('roomNumberError').style.display = 'none';
    }

    if (!form.checkValidity()) { e.preventDefault(); e.stopPropagation(); }
    form.classList.add('was-validated');
});

// ── Checkout min = checkin + 1 day ────────────────────────────────────────────
function updateCheckoutMin() {
    const cin = document.getElementById('checkIn').value;
    if (cin) {
        const next = new Date(cin);
        next.setDate(next.getDate() + 1);
        const minOut = next.toISOString().split('T')[0];
        document.getElementById('checkOut').min = minOut;
        const cout = document.getElementById('checkOut');
        if (cout.value && cout.value <= cin) cout.value = '';
    }
    estimateCost();
}

// ── Cost estimate ─────────────────────────────────────────────────────────────
function estimateCost() {
    const prices = { Standard: 10000, Deluxe: 15000, Suite: 25000 };
    const room  = document.getElementById('roomType').value;
    const cin   = document.getElementById('checkIn').value;
    const cout  = document.getElementById('checkOut').value;
    if (room && cin && cout && cout > cin) {
        const nights = (new Date(cout) - new Date(cin)) / 86400000;
        document.getElementById('costPreview').textContent =
            'LKR ' + (nights * (prices[room]||0)).toLocaleString('en-LK',{minimumFractionDigits:2});
    } else {
        document.getElementById('costPreview').textContent = '—';
    }
}

// ── Load available rooms via AJAX ─────────────────────────────────────────────
let loadTimer = null;
function loadAvailableRooms() {
    estimateCost();
    clearTimeout(loadTimer);
    loadTimer = setTimeout(_doLoadRooms, 300);
}

function _doLoadRooms() {
    const roomType = document.getElementById('roomType').value;
    const checkIn  = document.getElementById('checkIn').value;
    const checkOut = document.getElementById('checkOut').value;
    const container = document.getElementById('roomButtons');

    if (!roomType || !checkIn || !checkOut) {
        container.innerHTML = '<span class="text-muted small">Select room type and dates to see available rooms</span>';
        return;
    }

    container.innerHTML = '<span class="text-muted small"><i class="fas fa-spinner fa-spin me-1"></i>Loading rooms...</span>';

    fetch(ctx + '/reservation?action=availableRooms&roomType=' + roomType +
          '&checkIn=' + checkIn + '&checkOut=' + checkOut,
          {credentials: 'same-origin'})
    .then(function(r) { return r.json(); })
    .then(function(available) {
        // All rooms for this type
        var allRooms = {
            'Standard': ['101','102','103','104','105','106','107'],
            'Deluxe':   ['201','202','203','204'],
            'Suite':    ['301','302','303']
        };
        var rooms = allRooms[roomType] || [];
        var selectedRoom = document.getElementById('roomNumber').value;
        var html = '';

        if (rooms.length === 0) {
            container.innerHTML = '<span class="text-danger small">Unknown room type: ' + roomType + '</span>';
            return;
        }

        rooms.forEach(function(room) {
            // Trim to avoid whitespace mismatch issues
            var roomTrimmed = room.trim();
            var isAvail = false;
            for (var i = 0; i < available.length; i++) {
                if (available[i].trim() === roomTrimmed) { isAvail = true; break; }
            }
            var isSel = roomTrimmed === selectedRoom;

            if (isAvail) {
                // Available room – green, clickable
                html += '<button type="button"'
                      + ' class="room-btn' + (isSel ? ' selected' : '') + '"'
                      + ' onclick="selectRoom(\'' + roomTrimmed + '\')"'
                      + ' title="Available – click to select">'
                      + '<i class="fas fa-door-open me-1"></i>Room ' + roomTrimmed
                      + '</button>';
            } else {
                // Booked room – red, not clickable
                html += '<button type="button"'
                      + ' class="room-btn unavailable"'
                      + ' disabled'
                      + ' title="Already booked for these dates">'
                      + '<i class="fas fa-door-open me-1"></i>Room ' + roomTrimmed
                      + '<br><small>Booked</small>'
                      + '</button>';
            }
        });

        if (available.length === 0) {
            html += '<div class="alert alert-warning py-2 mt-2 w-100">'
                  + '<i class="fas fa-exclamation-triangle me-2"></i>'
                  + 'No ' + roomType + ' rooms available for these dates!</div>';
        }

        container.innerHTML = html;
    })
    .catch(function(err) {
        console.error('Room load error:', err);
        container.innerHTML = '<span class="text-danger small">Could not load rooms. Please try again.</span>';
    });
}

function selectRoom(roomNum) {
    document.getElementById('roomNumber').value = roomNum;
    document.getElementById('roomNumberError').style.display = 'none';
    // Update button styles
    document.querySelectorAll('.room-btn').forEach(btn => {
        btn.classList.remove('selected');
        if (btn.textContent.includes('Room ' + roomNum)) btn.classList.add('selected');
    });
}

// ── Guest auto-fill via AJAX ──────────────────────────────────────────────────
let lookupTimer = null;
function lookupGuest(value) {
    clearTimeout(lookupTimer);
    if (value.length < 5) return;
    lookupTimer = setTimeout(() => _doLookup(value), 500);
}

function _doLookup(nationalId) {
    document.getElementById('lookupSpinner').style.display = 'flex';
    fetch(ctx + '/reservation?action=guestLookup&nationalId=' + encodeURIComponent(nationalId),
          {credentials: 'same-origin'})
    .then(r => r.json())
    .then(data => {
        document.getElementById('lookupSpinner').style.display = 'none';
        if (data.found) {
            document.getElementById('guestName').value      = data.guestName;
            document.getElementById('address').value        = data.address;
            document.getElementById('contactNumber').value  = data.contactNumber;
            document.getElementById('email').value          = data.email;

            document.getElementById('returningAlert').style.display = 'block';
            if (data.isVip) {
                document.getElementById('vipBadge').style.display    = 'inline';
                document.getElementById('vipNotice').innerHTML = ' &nbsp;<span class="vip-badge">⭐ VIP Guest</span>';
            } else {
                document.getElementById('vipBadge').style.display = 'none';
                document.getElementById('vipNotice').innerHTML = '';
            }
        } else {
            document.getElementById('returningAlert').style.display = 'none';
            document.getElementById('vipBadge').style.display       = 'none';
        }
    })
    .catch(() => { document.getElementById('lookupSpinner').style.display = 'none'; });
}
</script>
</body>
</html>
