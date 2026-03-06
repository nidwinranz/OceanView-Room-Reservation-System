<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Determine which step to show (default = email entry)
    String step       = (String) request.getAttribute("step");
    String email      = (String) request.getAttribute("email");
    String otpCode    = (String) request.getAttribute("otpCode");
    String errorMsg   = (String) request.getAttribute("error");
    String successMsg = (String) request.getAttribute("successMsg");

    if (step == null)  step  = "email";
    if (email == null) email = "";

    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Forgot Password – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <style>
    body {
      background: linear-gradient(135deg,#0a3d62 0%,#1a6b8a 50%,#48b0cc 100%);
      min-height: 100vh;
      display: flex; align-items: center; justify-content: center;
      padding: 20px;
    }
    .otp-card {
      background: rgba(255,255,255,0.97);
      border-radius: 16px;
      box-shadow: 0 20px 60px rgba(0,0,0,0.3);
      overflow: hidden;
      max-width: 440px; width: 100%;
    }
    .card-header-custom {
      background: linear-gradient(135deg,#0a3d62,#1a6b8a);
      padding: 28px 24px; text-align: center; color: #fff;
    }
    .card-header-custom h4 { font-size:1.4rem; font-weight:700; margin:8px 0 4px; }
    .card-header-custom p  { font-size:0.85rem; opacity:0.85; margin:0; }

    /* Step indicator */
    .steps { display:flex; justify-content:center; gap:8px; margin-bottom:24px; }
    .step-dot {
      width:10px; height:10px; border-radius:50%;
      background:#dee2e6; transition:background 0.3s;
    }
    .step-dot.active  { background:#0a3d62; }
    .step-dot.done    { background:#27ae60; }

    /* OTP input boxes */
    .otp-inputs { display:flex; gap:10px; justify-content:center; }
    .otp-inputs input {
      width:48px; height:56px; text-align:center;
      font-size:1.5rem; font-weight:700;
      border:2px solid #ced4da; border-radius:10px;
      outline:none; transition:border-color 0.2s;
    }
    .otp-inputs input:focus { border-color:#0a3d62; box-shadow:0 0 0 3px rgba(10,61,98,0.15); }

    /* Timer badge */
    .timer-badge {
      background:#fff3cd; border:1px solid #ffc107;
      border-radius:20px; padding:4px 14px;
      font-size:0.8rem; font-weight:600; color:#856404;
      display:inline-block;
    }

    .btn-primary-custom {
      background:linear-gradient(135deg,#0a3d62,#1a6b8a);
      border:none; color:#fff; width:100%;
      padding:0.75rem; border-radius:10px;
      font-weight:700; font-size:1rem; transition:opacity 0.2s;
    }
    .btn-primary-custom:hover { opacity:0.9; color:#fff; }
    .back-link { font-size:0.85rem; text-align:center; margin-top:14px; }
    .back-link a { color:#1a6b8a; text-decoration:none; }
    .back-link a:hover { text-decoration:underline; }

    /* Password strength bar */
    .strength-bar { height:5px; border-radius:3px; margin-top:6px;
                    transition:all 0.3s; background:#dee2e6; }
    .strength-weak   { background:#e74c3c; width:33%; }
    .strength-medium { background:#f39c12; width:66%; }
    .strength-strong { background:#27ae60; width:100%; }
  </style>
</head>
<body>

<div class="otp-card">

  <!-- Card Header -->
  <div class="card-header-custom">
    <i class="fas fa-umbrella-beach fa-2x"></i>
    <h4>Ocean View Resort</h4>
    <p>
      <% if ("email".equals(step)) { %>
        <i class="fas fa-lock me-1"></i>Password Reset
      <% } else if ("verify".equals(step)) { %>
        <i class="fas fa-shield-alt me-1"></i>Verify OTP
      <% } else { %>
        <i class="fas fa-key me-1"></i>Set New Password
      <% } %>
    </p>
  </div>

  <div class="p-4">

    <!-- Step Indicator -->
    <div class="steps">
      <div class="step-dot <%= "email".equals(step) ? "active" : "done" %>"></div>
      <div class="step-dot <%= "verify".equals(step) ? "active" : ("reset".equals(step) ? "done" : "") %>"></div>
      <div class="step-dot <%= "reset".equals(step) ? "active" : "" %>"></div>
    </div>
    <p class="text-center text-muted small mb-4">
      <% if ("email".equals(step)) { %>Step 1 of 3 – Enter your email
      <% } else if ("verify".equals(step)) { %>Step 2 of 3 – Enter the OTP
      <% } else { %>Step 3 of 3 – Set new password<% } %>
    </p>

    <!-- Alerts -->
    <% if (errorMsg != null) { %>
      <div class="alert alert-danger py-2 small">
        <i class="fas fa-exclamation-circle me-2"></i><%= errorMsg %>
      </div>
    <% } %>
    <% if (successMsg != null) { %>
      <div class="alert alert-success py-2 small">
        <i class="fas fa-check-circle me-2"></i><%= successMsg %>
      </div>
    <% } %>

    <!-- ════════════════════════════════════════════════════════════════════ -->
    <!-- STEP 1 – Email Entry                                                -->
    <!-- ════════════════════════════════════════════════════════════════════ -->
    <% if ("email".equals(step)) { %>
    <form method="post" action="<%= ctx %>/forgot-password?step=email" id="emailForm" novalidate>

      <div class="mb-4">
        <label class="form-label fw-semibold" for="email">
          <i class="fas fa-envelope me-1 text-primary"></i>Admin Email Address
        </label>
        <input type="email" id="email" name="email" class="form-control form-control-lg"
               placeholder="Enter your registered email"
               value="<%= email %>" required/>
        <div class="form-text">
          Enter the email address registered to your admin account.
        </div>
        <div class="invalid-feedback">Please enter a valid email address.</div>
      </div>

      <button type="submit" class="btn btn-primary-custom">
        <i class="fas fa-paper-plane me-2"></i>Send OTP to My Email
      </button>

      <div class="back-link mt-3">
        <a href="<%= ctx %>/login"><i class="fas fa-arrow-left me-1"></i>Back to Login</a>
      </div>
    </form>
    <% } %>

    <!-- ════════════════════════════════════════════════════════════════════ -->
    <!-- STEP 2 – OTP Verification                                           -->
    <!-- ════════════════════════════════════════════════════════════════════ -->
    <% if ("verify".equals(step)) { %>
    <div class="text-center mb-4">
      <p class="text-muted small mb-2">OTP sent to:</p>
      <strong class="text-primary"><%= email %></strong>
      <br/>
      <span class="timer-badge mt-2" id="timer">
        <i class="fas fa-clock me-1"></i><span id="countdown">10:00</span> remaining
      </span>
    </div>

    <form method="post" action="<%= ctx %>/forgot-password?step=verify" id="otpForm">
      <input type="hidden" name="email" value="<%= email %>"/>

      <label class="form-label fw-semibold text-center d-block mb-3">
        <i class="fas fa-shield-alt me-1 text-primary"></i>Enter 6-Digit OTP
      </label>

      <!-- 6 individual OTP input boxes -->
      <div class="otp-inputs mb-3" id="otpBoxes">
        <input type="text" maxlength="1" class="otp-box" id="otp1" inputmode="numeric"/>
        <input type="text" maxlength="1" class="otp-box" id="otp2" inputmode="numeric"/>
        <input type="text" maxlength="1" class="otp-box" id="otp3" inputmode="numeric"/>
        <input type="text" maxlength="1" class="otp-box" id="otp4" inputmode="numeric"/>
        <input type="text" maxlength="1" class="otp-box" id="otp5" inputmode="numeric"/>
        <input type="text" maxlength="1" class="otp-box" id="otp6" inputmode="numeric"/>
      </div>
      <!-- Hidden field that combines all 6 digits -->
      <input type="hidden" name="otpCode" id="otpCode"/>

      <button type="submit" class="btn btn-primary-custom" id="verifyBtn">
        <i class="fas fa-check-circle me-2"></i>Verify OTP
      </button>

      <div class="text-center mt-3">
        <a href="<%= ctx %>/forgot-password" class="text-muted small">
          <i class="fas fa-redo me-1"></i>Resend OTP
        </a>
      </div>
    </form>
    <% } %>

    <!-- ════════════════════════════════════════════════════════════════════ -->
    <!-- STEP 3 – New Password                                               -->
    <!-- ════════════════════════════════════════════════════════════════════ -->
    <% if ("reset".equals(step)) { %>
    <form method="post" action="<%= ctx %>/forgot-password?step=reset" id="resetForm" novalidate>
      <input type="hidden" name="email"   value="<%= email %>"/>
      <input type="hidden" name="otpCode" value="<%= otpCode %>"/>

      <div class="mb-3">
        <label class="form-label fw-semibold" for="newPassword">
          <i class="fas fa-lock me-1 text-primary"></i>New Password
        </label>
        <div class="input-group">
          <input type="password" id="newPassword" name="newPassword"
                 class="form-control" placeholder="Min 6 characters"
                 required minlength="6" oninput="checkStrength(this.value)"/>
          <button class="btn btn-outline-secondary" type="button"
                  onclick="toggleVis('newPassword',this)">
            <i class="fas fa-eye"></i>
          </button>
        </div>
        <!-- Strength bar -->
        <div class="strength-bar" id="strengthBar"></div>
        <div class="form-text" id="strengthText"></div>
        <div class="invalid-feedback">Password must be at least 6 characters.</div>
      </div>

      <div class="mb-4">
        <label class="form-label fw-semibold" for="confirmPassword">
          <i class="fas fa-lock me-1 text-primary"></i>Confirm New Password
        </label>
        <div class="input-group">
          <input type="password" id="confirmPassword" name="confirmPassword"
                 class="form-control" placeholder="Re-enter new password" required/>
          <button class="btn btn-outline-secondary" type="button"
                  onclick="toggleVis('confirmPassword',this)">
            <i class="fas fa-eye"></i>
          </button>
        </div>
        <div class="invalid-feedback">Passwords must match.</div>
      </div>

      <button type="submit" class="btn btn-primary-custom">
        <i class="fas fa-save me-2"></i>Reset Password
      </button>
    </form>
    <% } %>

  </div><!-- /p-4 -->
</div><!-- /otp-card -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>

// ── Email form validation ────────────────────────────────────────────────────
const emailForm = document.getElementById('emailForm');
if (emailForm) {
  emailForm.addEventListener('submit', function(e) {
    if (!emailForm.checkValidity()) { e.preventDefault(); e.stopPropagation(); }
    emailForm.classList.add('was-validated');
  });
}

// ── OTP box auto-advance + combine ──────────────────────────────────────────
const boxes = document.querySelectorAll('.otp-box');
if (boxes.length) {
  boxes.forEach((box, idx) => {
    box.addEventListener('input', function() {
      this.value = this.value.replace(/[^0-9]/g, '');
      if (this.value && idx < boxes.length - 1) boxes[idx + 1].focus();
      combineOtp();
    });
    box.addEventListener('keydown', function(e) {
      if (e.key === 'Backspace' && !this.value && idx > 0) boxes[idx - 1].focus();
    });
    // Handle paste: spread digits across boxes
    box.addEventListener('paste', function(e) {
      e.preventDefault();
      const pasted = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g,'');
      [...pasted].slice(0, 6).forEach((ch, i) => { if (boxes[i]) boxes[i].value = ch; });
      combineOtp();
      const next = Math.min(pasted.length, 5);
      boxes[next].focus();
    });
  });
  boxes[0].focus();
}

function combineOtp() {
  const combined = [...boxes].map(b => b.value).join('');
  const hidden   = document.getElementById('otpCode');
  if (hidden) hidden.value = combined;
}

const otpForm = document.getElementById('otpForm');
if (otpForm) {
  otpForm.addEventListener('submit', function(e) {
    e.preventDefault(); // ← Stop form first
    combineOtp();       // ← Then combine
    const otp = document.getElementById('otpCode').value;
    if (otp.length !== 6) {
      alert('Please enter all 6 digits of the OTP.');
    } else {
      otpForm.submit(); // ← Now submit with filled hidden field
    }
  });
}

// ── Countdown timer (10 minutes) ─────────────────────────────────────────────
const countdownEl = document.getElementById('countdown');
if (countdownEl) {
  let seconds = 10 * 60;
  const timer = setInterval(function() {
    seconds--;
    const m = Math.floor(seconds / 60).toString().padStart(2, '0');
    const s = (seconds % 60).toString().padStart(2, '0');
    countdownEl.textContent = m + ':' + s;
    if (seconds <= 0) {
      clearInterval(timer);
      countdownEl.textContent = 'Expired';
      document.getElementById('verifyBtn').disabled = true;
      document.getElementById('timer').classList.replace('timer-badge','alert alert-danger');
    }
  }, 1000);
}

// ── Password strength checker ────────────────────────────────────────────────
function checkStrength(val) {
  const bar  = document.getElementById('strengthBar');
  const text = document.getElementById('strengthText');
  if (!bar) return;
  if (val.length === 0) { bar.className='strength-bar'; text.textContent=''; return; }
  let score = 0;
  if (val.length >= 6)  score++;
  if (val.length >= 10) score++;
  if (/[A-Z]/.test(val) && /[0-9]/.test(val)) score++;
  if (score === 1) { bar.className='strength-bar strength-weak';   text.textContent='Weak'; text.style.color='#e74c3c'; }
  if (score === 2) { bar.className='strength-bar strength-medium'; text.textContent='Medium'; text.style.color='#f39c12'; }
  if (score === 3) { bar.className='strength-bar strength-strong'; text.textContent='Strong'; text.style.color='#27ae60'; }
}

// ── Reset form: password match validation ────────────────────────────────────
const resetForm = document.getElementById('resetForm');
if (resetForm) {
  resetForm.addEventListener('submit', function(e) {
    const pw  = document.getElementById('newPassword').value;
    const cpw = document.getElementById('confirmPassword').value;
    if (pw !== cpw) {
      document.getElementById('confirmPassword').setCustomValidity('Passwords do not match.');
    } else {
      document.getElementById('confirmPassword').setCustomValidity('');
    }
    if (!resetForm.checkValidity()) { e.preventDefault(); e.stopPropagation(); }
    resetForm.classList.add('was-validated');
  });
}

// ── Show/hide password ───────────────────────────────────────────────────────
function toggleVis(id, btn) {
  const f = document.getElementById(id);
  const i = btn.querySelector('i');
  f.type = f.type === 'password' ? 'text' : 'password';
  i.classList.toggle('fa-eye');
  i.classList.toggle('fa-eye-slash');
}
</script>
</body>
</html>
