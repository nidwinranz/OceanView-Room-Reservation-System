<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession cp = request.getSession(false);
    if (cp == null || cp.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    if (!"ADMIN".equals(cp.getAttribute("userRole"))) {
        response.sendRedirect(request.getContextPath() + "/access-denied"); return;
    }

    String step      = (String) request.getAttribute("step");
    if (step == null) step = "email";

    String ctx       = request.getContextPath();
    String user      = (String) cp.getAttribute("loggedInUser");
    String errorMsg  = (String) request.getAttribute("error");
    String successMsg= (String) request.getAttribute("success");
    String savedEmail= (String) request.getAttribute("savedEmail");
    String maskedEmail=(String) request.getAttribute("email");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Change Password – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="<%= ctx %>/css/style.css" rel="stylesheet"/>
  <style>
    body { background: linear-gradient(135deg,#0a3d62 0%,#1a6b8a 50%,#48b0cc 100%); min-height:100vh; }
    .reset-card { max-width:480px; width:100%; margin:60px auto; border-radius:16px; overflow:hidden; box-shadow:0 20px 60px rgba(0,0,0,0.3); }
    .reset-header { background:linear-gradient(135deg,#0a3d62,#1a6b8a); padding:2rem; text-align:center; color:#fff; }
    .reset-header h4 { font-weight:800; margin:0; }
    .reset-body { background:#fff; padding:2rem; }
    /* Step progress bar */
    .step-bar { display:flex; align-items:center; justify-content:center; gap:0; margin-bottom:2rem; }
    .step-item { display:flex; flex-direction:column; align-items:center; flex:1; }
    .step-circle {
      width:38px; height:38px; border-radius:50%; border:2px solid #dee2e6;
      display:flex; align-items:center; justify-content:center;
      font-weight:700; font-size:14px; background:#fff; color:#aaa;
      position:relative; z-index:1;
    }
    .step-circle.active  { border-color:#0a3d62; background:#0a3d62; color:#fff; }
    .step-circle.done    { border-color:#27ae60; background:#27ae60; color:#fff; }
    .step-label { font-size:11px; color:#aaa; margin-top:4px; font-weight:600; text-transform:uppercase; }
    .step-label.active { color:#0a3d62; }
    .step-line { height:2px; background:#dee2e6; flex:1; margin-top:-18px; }
    .step-line.done { background:#27ae60; }
    /* OTP input boxes */
    .otp-inputs { display:flex; gap:10px; justify-content:center; margin:20px 0; }
    .otp-box {
      width:50px; height:58px; text-align:center; font-size:24px; font-weight:700;
      border:2px solid #dee2e6; border-radius:10px; outline:none;
      transition:border-color 0.2s, box-shadow 0.2s;
    }
    .otp-box:focus { border-color:#0a3d62; box-shadow:0 0 0 3px rgba(10,61,98,0.15); }
    .otp-box.filled { border-color:#27ae60; background:#f0fff4; }
    .btn-primary-custom {
      background:linear-gradient(135deg,#0a3d62,#1a6b8a); border:none;
      color:#fff; width:100%; padding:0.75rem; border-radius:10px;
      font-weight:700; font-size:1rem; transition:opacity 0.2s;
    }
    .btn-primary-custom:hover { opacity:0.9; color:#fff; }
  </style>
</head>
<body>
<div class="container">
<div class="reset-card">

  <!-- Header -->
  <div class="reset-header">
    <i class="fas fa-shield-alt fa-2x mb-2"></i>
    <h4>Change Admin Password</h4>
    <p class="mb-0 small" style="opacity:0.85;">
      <i class="fas fa-user-circle me-1"></i><%= user %>
      &nbsp;<span class="badge bg-warning text-dark">ADMIN</span>
    </p>
  </div>

  <div class="reset-body">

    <!-- ── Step Progress Bar ───────────────────────────────────────────────── -->
    <div class="step-bar">
      <div class="step-item">
        <div class="step-circle <%= (step.equals("email")) ? "active" : "done" %>">
          <% if (!step.equals("email")) { %><i class="fas fa-check"></i><% } else { %>1<% } %>
        </div>
        <div class="step-label <%= step.equals("email") ? "active" : "" %>">Email</div>
      </div>
      <div class="step-line <%= (!step.equals("email")) ? "done" : "" %>"></div>
      <div class="step-item">
        <div class="step-circle
          <%= step.equals("otp") ? "active" : (step.equals("newpassword")||step.equals("done")) ? "done" : "" %>">
          <% if (step.equals("newpassword") || step.equals("done")) { %><i class="fas fa-check"></i><% } else { %>2<% } %>
        </div>
        <div class="step-label <%= step.equals("otp") ? "active" : "" %>">Verify OTP</div>
      </div>
      <div class="step-line <%= (step.equals("newpassword")||step.equals("done")) ? "done" : "" %>"></div>
      <div class="step-item">
        <div class="step-circle
          <%= step.equals("newpassword") ? "active" : step.equals("done") ? "done" : "" %>">
          <% if (step.equals("done")) { %><i class="fas fa-check"></i><% } else { %>3<% } %>
        </div>
        <div class="step-label <%= step.equals("newpassword") ? "active" : "" %>">New Password</div>
      </div>
    </div>

    <!-- ── Alerts ─────────────────────────────────────────────────────────── -->
    <% if (errorMsg != null) { %>
      <div class="alert alert-danger alert-dismissible fade show">
        <i class="fas fa-exclamation-circle me-2"></i><%= errorMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    <% } %>
    <% if (successMsg != null) { %>
      <div class="alert alert-success">
        <i class="fas fa-check-circle me-2"></i><%= successMsg %>
      </div>
    <% } %>

    <!-- ════════════════════════════════════════════════════════════════════ -->
    <!-- STEP 1: Enter Email                                                  -->
    <!-- ════════════════════════════════════════════════════════════════════ -->
    <% if (step.equals("email")) { %>
      <h5 class="fw-bold mb-1"><i class="fas fa-envelope me-2 text-primary"></i>Enter Your Email</h5>
      <p class="text-muted small mb-4">We'll send a 6-digit OTP code to your email address.</p>

      <form method="post" action="<%= ctx %>/change-password?step=otp" novalidate id="emailForm">
        <div class="mb-4">
          <label class="form-label fw-semibold" for="email">Admin Email Address</label>
          <div class="input-group">
            <span class="input-group-text"><i class="fas fa-envelope text-primary"></i></span>
            <input type="email" id="email" name="email" class="form-control form-control-lg"
                   placeholder="yourname@gmail.com"
                   value="<%= savedEmail != null ? savedEmail : "" %>"
                   required autofocus/>
          </div>
          <div class="form-text">Enter the email linked to your admin account.</div>
        </div>
        <button type="submit" class="btn btn-primary-custom">
          <i class="fas fa-paper-plane me-2"></i>Send OTP Code
        </button>
      </form>

    <!-- ════════════════════════════════════════════════════════════════════ -->
    <!-- STEP 2: Enter OTP                                                    -->
    <!-- ════════════════════════════════════════════════════════════════════ -->
    <% } else if (step.equals("otp")) { %>
      <h5 class="fw-bold mb-1"><i class="fas fa-key me-2 text-warning"></i>Enter OTP Code</h5>
      <p class="text-muted small mb-1">
        A 6-digit code was sent to <strong><%= maskedEmail != null ? maskedEmail : "your email" %></strong>
      </p>
      <p class="text-danger small mb-4"><i class="fas fa-clock me-1"></i>Expires in 10 minutes</p>

      <form method="post" action="<%= ctx %>/change-password?step=verify" id="otpForm">

        <!-- 6 individual OTP input boxes -->
        <div class="otp-inputs" id="otpBoxes">
          <input type="text" class="otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]"/>
          <input type="text" class="otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]"/>
          <input type="text" class="otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]"/>
          <input type="text" class="otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]"/>
          <input type="text" class="otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]"/>
          <input type="text" class="otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]"/>
        </div>
        <!-- Hidden field that holds the combined OTP value -->
        <input type="hidden" id="otpHidden" name="otp"/>

        <button type="submit" class="btn btn-primary-custom mb-3" id="verifyBtn" disabled>
          <i class="fas fa-check-circle me-2"></i>Verify OTP
        </button>

        <div class="text-center">
          <a href="<%= ctx %>/change-password" class="btn btn-link text-muted btn-sm">
            <i class="fas fa-arrow-left me-1"></i>Back / Resend OTP
          </a>
        </div>
      </form>

      <!-- Countdown timer -->
      <div class="text-center mt-3">
        <span class="text-muted small">Time remaining: </span>
        <span id="countdown" class="fw-bold text-danger">10:00</span>
      </div>

    <!-- ════════════════════════════════════════════════════════════════════ -->
    <!-- STEP 3: New Password                                                 -->
    <!-- ════════════════════════════════════════════════════════════════════ -->
    <% } else if (step.equals("newpassword")) { %>
      <h5 class="fw-bold mb-1"><i class="fas fa-lock me-2 text-success"></i>Set New Password</h5>
      <p class="text-muted small mb-4">OTP verified! Enter your new password below.</p>

      <form method="post" action="<%= ctx %>/change-password?step=reset" novalidate id="pwForm">

        <div class="mb-3">
          <label class="form-label fw-semibold" for="newPassword">New Password</label>
          <div class="input-group">
            <span class="input-group-text"><i class="fas fa-lock text-primary"></i></span>
            <input type="password" id="newPassword" name="newPassword"
                   class="form-control" placeholder="Min 6 characters"
                   required minlength="6" autofocus/>
            <button class="btn btn-outline-secondary" type="button" onclick="togglePw('newPassword',this)">
              <i class="fas fa-eye"></i>
            </button>
          </div>
          <!-- Password strength bar -->
          <div class="progress mt-2" style="height:6px;">
            <div id="strengthBar" class="progress-bar" style="width:0%;transition:width 0.3s;"></div>
          </div>
          <div id="strengthText" class="form-text"></div>
        </div>

        <div class="mb-4">
          <label class="form-label fw-semibold" for="confirmPassword">Confirm New Password</label>
          <div class="input-group">
            <span class="input-group-text"><i class="fas fa-lock text-primary"></i></span>
            <input type="password" id="confirmPassword" name="confirmPassword"
                   class="form-control" placeholder="Re-enter new password"
                   required minlength="6"/>
            <button class="btn btn-outline-secondary" type="button" onclick="togglePw('confirmPassword',this)">
              <i class="fas fa-eye"></i>
            </button>
          </div>
          <div id="matchMsg" class="form-text"></div>
        </div>

        <button type="submit" class="btn btn-primary-custom">
          <i class="fas fa-save me-2"></i>Save New Password
        </button>
      </form>

    <!-- ════════════════════════════════════════════════════════════════════ -->
    <!-- STEP 4: Done                                                         -->
    <!-- ════════════════════════════════════════════════════════════════════ -->
    <% } else if (step.equals("done")) { %>
      <div class="text-center py-3">
        <div class="rounded-circle bg-success d-inline-flex align-items-center justify-content-center mb-3"
             style="width:80px;height:80px;">
          <i class="fas fa-check fa-2x text-white"></i>
        </div>
        <h4 class="fw-bold text-success mb-2">Password Changed!</h4>
        <p class="text-muted mb-4">
          Your admin password has been updated successfully.<br/>
          Please log in again with your new password.
        </p>
        <a href="<%= ctx %>/logout" class="btn btn-primary-custom">
          <i class="fas fa-sign-in-alt me-2"></i>Log In Again
        </a>
      </div>
    <% } %>

    <!-- Back to dashboard link (except on done step) -->
    <% if (!step.equals("done")) { %>
    <div class="text-center mt-4">
      <a href="<%= ctx %>/dashboard" class="text-muted small text-decoration-none">
        <i class="fas fa-arrow-left me-1"></i>Back to Dashboard
      </a>
    </div>
    <% } %>

  </div><!-- /reset-body -->
</div><!-- /reset-card -->
</div><!-- /container -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// ── OTP Box auto-advance ──────────────────────────────────────────────────────
const boxes = document.querySelectorAll('.otp-box');
const hidden = document.getElementById('otpHidden');
const verifyBtn = document.getElementById('verifyBtn');

if (boxes.length > 0) {
    boxes.forEach((box, idx) => {
        box.addEventListener('input', function () {
            this.value = this.value.replace(/[^0-9]/g, '');
            if (this.value) {
                this.classList.add('filled');
                if (idx < boxes.length - 1) boxes[idx + 1].focus();
            } else {
                this.classList.remove('filled');
            }
            updateHidden();
        });
        box.addEventListener('keydown', function (e) {
            if (e.key === 'Backspace' && !this.value && idx > 0) {
                boxes[idx - 1].focus();
                boxes[idx - 1].value = '';
                boxes[idx - 1].classList.remove('filled');
                updateHidden();
            }
        });
        // Allow paste into first box
        box.addEventListener('paste', function (e) {
            e.preventDefault();
            const pasted = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g,'');
            pasted.split('').forEach((ch, i) => {
                if (boxes[i]) { boxes[i].value = ch; boxes[i].classList.add('filled'); }
            });
            updateHidden();
            if (boxes[pasted.length]) boxes[pasted.length].focus();
        });
    });
    boxes[0].focus();
}

function updateHidden() {
    if (!hidden) return;
    let val = '';
    boxes.forEach(b => val += b.value);
    hidden.value = val;
    if (verifyBtn) verifyBtn.disabled = val.length !== 6;
}

// ── OTP Countdown timer ───────────────────────────────────────────────────────
const countdownEl = document.getElementById('countdown');
if (countdownEl) {
    let secs = 600; // 10 minutes
    const timer = setInterval(() => {
        secs--;
        const m = Math.floor(secs / 60).toString().padStart(2, '0');
        const s = (secs % 60).toString().padStart(2, '0');
        countdownEl.textContent = m + ':' + s;
        if (secs <= 60)  countdownEl.style.color = '#e74c3c';
        if (secs <= 0) {
            clearInterval(timer);
            countdownEl.textContent = 'Expired';
            if (verifyBtn) { verifyBtn.disabled = true; verifyBtn.textContent = 'OTP Expired'; }
        }
    }, 1000);
}

// ── Password visibility toggle ────────────────────────────────────────────────
function togglePw(id, btn) {
    const f = document.getElementById(id);
    const i = btn.querySelector('i');
    f.type = f.type === 'password' ? 'text' : 'password';
    i.classList.toggle('fa-eye');
    i.classList.toggle('fa-eye-slash');
}

// ── Password strength meter ───────────────────────────────────────────────────
const newPwField = document.getElementById('newPassword');
if (newPwField) {
    newPwField.addEventListener('input', function () {
        const val = this.value;
        const bar = document.getElementById('strengthBar');
        const txt = document.getElementById('strengthText');
        let score = 0;
        if (val.length >= 6)  score++;
        if (val.length >= 10) score++;
        if (/[A-Z]/.test(val)) score++;
        if (/[0-9]/.test(val)) score++;
        if (/[^A-Za-z0-9]/.test(val)) score++;
        const levels = [
            { pct:'20%', color:'#e74c3c', label:'Very Weak' },
            { pct:'40%', color:'#e67e22', label:'Weak' },
            { pct:'60%', color:'#f1c40f', label:'Fair' },
            { pct:'80%', color:'#2ecc71', label:'Strong' },
            { pct:'100%',color:'#27ae60', label:'Very Strong' }
        ];
        const lv = levels[Math.min(score, 4)];
        bar.style.width = lv.pct;
        bar.style.backgroundColor = lv.color;
        txt.textContent = 'Strength: ' + lv.label;
        txt.style.color = lv.color;
    });
}

// ── Password match checker ────────────────────────────────────────────────────
const confirmPwField = document.getElementById('confirmPassword');
if (confirmPwField) {
    confirmPwField.addEventListener('input', function () {
        const match = document.getElementById('matchMsg');
        if (this.value === newPwField.value) {
            match.textContent = '✅ Passwords match';
            match.style.color = '#27ae60';
        } else {
            match.textContent = '❌ Passwords do not match';
            match.style.color = '#e74c3c';
        }
    });
}

// ── New password form validation ──────────────────────────────────────────────
const pwForm = document.getElementById('pwForm');
if (pwForm) {
    pwForm.addEventListener('submit', function (e) {
        const p1 = document.getElementById('newPassword').value;
        const p2 = document.getElementById('confirmPassword').value;
        if (p1 !== p2) {
            e.preventDefault();
            document.getElementById('confirmPassword').setCustomValidity('Passwords do not match');
            pwForm.classList.add('was-validated');
        } else {
            document.getElementById('confirmPassword').setCustomValidity('');
        }
    });
}
</script>
</body>
</html>
