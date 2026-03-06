<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession ds = request.getSession(false);
    if (ds == null || ds.getAttribute("loggedInUser") == null) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    String user     = (String)  ds.getAttribute("loggedInUser");
    String role     = (String)  ds.getAttribute("userRole");
    boolean isAdmin = "ADMIN".equals(role);

    Integer totalAttr  = (Integer) request.getAttribute("totalReservations");
    Integer activeAttr = (Integer) request.getAttribute("activeCount");
    int    total  = (totalAttr  != null) ? totalAttr  : 0;
    int    active = (activeAttr != null) ? activeAttr : 0;
    Double income = isAdmin ? (Double) request.getAttribute("totalIncome") : null;
    String ctx    = request.getContextPath();

    // FIX: pre-compute badge class to avoid quote conflicts inside JSP expressions
    String roleBadgeClass = isAdmin ? "badge-role badge-admin" : "badge-role badge-staff";
    String roleIcon       = isAdmin ? "fa-crown" : "fa-user-tie";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Dashboard – Ocean View Resort</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet"/>
  <link href="<%= ctx %>/css/style.css" rel="stylesheet"/>
  <style>
    :root {
      --navy:        #0E1A2B;
      --navy-mid:    #152434;
      --navy-light:  #1C3050;
      --gold:        #D4AF37;
      --gold-light:  #E8D070;
      --gold-dim:    rgba(212,175,55,0.18);
      --ivory:       #F8F6F1;
      --ivory-dim:   rgba(248,246,241,0.06);
      --charcoal:    #2B2B2B;
      --muted:       rgba(248,246,241,0.55);
      --glass-bg:    rgba(255,255,255,0.05);
      --glass-border:rgba(212,175,55,0.22);
      --shadow-card: 0 8px 32px rgba(0,0,0,0.35);
      --shadow-hover:0 18px 48px rgba(0,0,0,0.48);
      --radius-lg:   16px;
      --radius-md:   12px;
      --transition:  0.32s cubic-bezier(0.4,0,0.2,1);
    }
    *,*::before,*::after { box-sizing:border-box; margin:0; padding:0; }
    body {
      background: var(--navy);
      color: var(--ivory);
      font-family: 'Inter', sans-serif;
      min-height: 100vh;
      overflow-x: hidden;
    }

    /* ── NAVBAR ── */
    .luxury-nav {
      background: rgba(14,26,43,0.92) !important;
      backdrop-filter: blur(18px) saturate(1.4);
      border-bottom: 1px solid var(--glass-border);
      padding: 0.55rem 0;
      position: sticky; top: 0; z-index: 1050;
    }
    .luxury-nav .navbar-brand {
      font-family: 'Playfair Display', serif;
      font-size: 1.22rem; font-weight: 700;
      color: var(--gold) !important;
      letter-spacing: 0.04em;
      display: flex; align-items: center; gap: 0.55rem;
    }
    .luxury-nav .brand-icon {
      width:32px; height:32px;
      background: var(--gold-dim);
      border: 1px solid var(--glass-border);
      border-radius: 8px;
      display: flex; align-items: center; justify-content: center;
      font-size: 0.88rem; color: var(--gold);
    }
    .luxury-nav .nav-link {
      color: var(--muted) !important;
      font-size: 0.82rem; font-weight: 500;
      letter-spacing: 0.03em;
      padding: 0.45rem 0.85rem !important;
      border-radius: 6px;
      transition: color var(--transition), background var(--transition);
    }
    .luxury-nav .nav-link:hover,
    .luxury-nav .nav-link.active {
      color: var(--ivory) !important;
      background: var(--ivory-dim);
    }
    .badge-role {
      font-size: 0.68rem; font-weight: 600;
      letter-spacing: 0.1em;
      padding: 0.38rem 0.75rem;
      border-radius: 100px;
      text-transform: uppercase;
    }
    .badge-admin {
      background: var(--gold-dim);
      border: 1px solid var(--gold);
      color: var(--gold);
    }
    .badge-staff {
      background: rgba(100,200,220,0.12);
      border: 1px solid rgba(100,200,220,0.4);
      color: #8de8f8;
    }
    .nav-user-btn { color: var(--muted) !important; font-size: 0.82rem; }
    .nav-user-btn:hover { color: var(--ivory) !important; }
    .luxury-dropdown {
      background: var(--navy-mid) !important;
      border: 1px solid var(--glass-border) !important;
      border-radius: var(--radius-md) !important;
      box-shadow: 0 12px 40px rgba(0,0,0,0.5) !important;
    }
    .luxury-dropdown .dropdown-item {
      color: var(--muted); font-size: 0.82rem;
      border-radius: 8px; margin: 2px 4px;
      transition: background var(--transition), color var(--transition);
    }
    .luxury-dropdown .dropdown-item:hover { background: var(--ivory-dim); color: var(--ivory); }
    .luxury-dropdown .dropdown-item.text-danger { color: #f87e7e !important; }
    .luxury-dropdown .dropdown-item.text-danger:hover { background: rgba(248,126,126,0.12); }
    .luxury-dropdown .dropdown-divider { border-color: var(--glass-border); }
    .luxury-dropdown .dropdown-item-text { color: var(--muted) !important; font-size: 0.76rem; }

    /* ── HERO ── */
    .dashboard-hero {
      position: relative; padding: 3.5rem 2rem 2.5rem; overflow: hidden;
      background: var(--navy-mid);
    }
    .dashboard-hero::before {
      content: '';
      position: absolute; inset: 0;
      background:
        linear-gradient(135deg,rgba(14,26,43,0.88) 0%,rgba(21,36,52,0.72) 60%,rgba(212,175,55,0.08) 100%),
        url('https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1600&q=80&auto=format&fit=crop') center/cover no-repeat;
    }
    .dashboard-hero::after {
      content: ''; position: absolute; bottom:0; left:0; right:0; height:80px;
      background: linear-gradient(to bottom, transparent, var(--navy));
    }
    .dashboard-hero .hero-content { position: relative; z-index: 2; }
    .dashboard-hero h2 {
      font-family: 'Playfair Display', serif;
      font-size: clamp(1.8rem,3.5vw,2.6rem);
      font-weight: 700; color: var(--ivory);
    }
    .dashboard-hero h2 span { color: var(--gold); }
    .dashboard-hero .hero-sub { color: var(--muted); font-size: 0.9rem; margin-top: 0.35rem; }
    .dashboard-hero .hero-sub strong { color: var(--ivory); }
    .btn-gold {
      background: linear-gradient(135deg, var(--gold), var(--gold-light));
      color: var(--navy); border: none;
      font-weight: 600; font-size: 0.84rem;
      letter-spacing: 0.04em;
      padding: 0.6rem 1.4rem; border-radius: 100px;
      box-shadow: 0 4px 18px rgba(212,175,55,0.35);
      transition: transform var(--transition), box-shadow var(--transition);
      display: inline-flex; align-items: center; gap: 0.4rem;
      text-decoration: none;
    }
    .btn-gold:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 30px rgba(212,175,55,0.55);
      color: var(--navy);
    }

    /* ── BODY / SECTIONS ── */
    .dashboard-body { background: var(--navy); padding: 2rem 1.5rem 4rem; }
    .section-label {
      font-size: 0.7rem; font-weight: 600;
      letter-spacing: 0.18em; text-transform: uppercase;
      color: var(--gold); margin-bottom: 0.25rem; display: block;
    }
    .section-title {
      font-family: 'Playfair Display', serif;
      font-size: 1.35rem; font-weight: 600;
      color: var(--ivory); margin-bottom: 1.35rem;
    }

    /* ── STAT CARDS ── */
    .stat-card {
      background: var(--glass-bg);
      border: 1px solid var(--glass-border) !important;
      border-radius: var(--radius-lg) !important;
      backdrop-filter: blur(12px);
      box-shadow: var(--shadow-card);
      transition: transform var(--transition), box-shadow var(--transition);
      overflow: hidden; position: relative;
    }
    .stat-card::before {
      content: ''; position: absolute;
      top:0; left:0; width:3px; height:100%; border-radius:3px 0 0 3px;
    }
    .stat-card.accent-blue::before  { background: linear-gradient(to bottom,#4fa3d1,#1a6b8a); }
    .stat-card.accent-green::before { background: linear-gradient(to bottom,#52d68a,#27ae60); }
    .stat-card.accent-gold::before  { background: linear-gradient(to bottom,var(--gold-light),var(--gold)); }
    .stat-card.accent-purple::before{ background: linear-gradient(to bottom,#c39bd3,#8e44ad); }
    .stat-card:hover { transform: translateY(-5px); box-shadow: var(--shadow-hover); }
    .stat-card .card-body { padding: 1.4rem 1.5rem; background: transparent; }
    .stat-label { font-size:0.72rem; font-weight:500; letter-spacing:0.08em; color:var(--muted); text-transform:uppercase; margin-bottom:0.3rem; }
    .stat-value { font-family:'Playfair Display',serif; font-size:2.4rem; font-weight:700; color:var(--ivory); line-height:1; }
    .stat-value.stat-value-sm { font-family:'Inter',sans-serif; font-size:1.1rem; font-weight:600; }
    .stat-value.text-gold { color: var(--gold); }
    .stat-icon-wrap {
      width:48px; height:48px; border-radius:12px;
      display:flex; align-items:center; justify-content:center;
      flex-shrink:0; font-size:1.1rem;
    }
    .stat-icon-wrap.blue   { background:rgba(79,163,209,0.14); color:#7dc6e8; }
    .stat-icon-wrap.green  { background:rgba(82,214,138,0.12);  color:#52d68a; }
    .stat-icon-wrap.gold   { background:var(--gold-dim);         color:var(--gold); }
    .stat-icon-wrap.purple { background:rgba(142,68,173,0.14);  color:#c39bd3; }

    /* ── QUICK CARDS ── */
    .quick-card {
      background: var(--glass-bg);
      border: 1px solid var(--glass-border) !important;
      border-radius: var(--radius-lg) !important;
      text-align: center; padding: 2rem 1rem !important;
      transition: transform var(--transition), box-shadow var(--transition), border-color var(--transition);
    }
    .quick-card:hover {
      transform: translateY(-4px) scale(1.02);
      box-shadow: var(--shadow-hover);
      border-color: var(--gold) !important;
    }
    .quick-card .q-icon {
      width:58px; height:58px; border-radius:14px;
      display:flex; align-items:center; justify-content:center;
      margin: 0 auto 1rem; font-size:1.4rem;
    }
    .quick-card h6 { font-size:0.88rem; font-weight:600; color:var(--ivory); margin-bottom:0.25rem; }
    .quick-card p  { font-size:0.75rem; color:var(--muted); margin:0; }
    .q-icon.blue   { background:rgba(79,163,209,0.14);  color:#7dc6e8; }
    .q-icon.teal   { background:rgba(32,201,203,0.12);  color:#20c9cb; }
    .q-icon.green  { background:rgba(82,214,138,0.12);  color:#52d68a; }
    .q-icon.gold   { background:var(--gold-dim);         color:var(--gold); }
    .q-icon.purple { background:rgba(142,68,173,0.14);  color:#c39bd3; }

    /* ── STAFF ALERT ── */
    .luxury-alert {
      background: rgba(32,180,200,0.08);
      border: 1px solid rgba(32,180,200,0.25) !important;
      border-radius: var(--radius-md);
      color: var(--muted); font-size: 0.84rem;
      padding: 1rem 1.4rem;
    }
    .luxury-alert strong { color: var(--ivory); }

    /* ── ROOM CARDS ── */
    .rooms-section {
      position: relative; border-radius: var(--radius-lg);
      overflow: hidden; margin-top: 2.5rem;
    }
    .rooms-parallax-bg {
      position: absolute; inset: -30px;
      background:
        linear-gradient(135deg,rgba(14,26,43,0.93) 0%,rgba(14,26,43,0.75) 50%,rgba(21,36,52,0.92) 100%),
        url('https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1600&q=80&auto=format&fit=crop') center/cover no-repeat;
    }
    .rooms-section-inner { position:relative; z-index:2; padding:2.4rem 2rem; }
    .rooms-section-header { text-align:center; margin-bottom:2rem; }
    .room-card {
      background: rgba(255,255,255,0.04);
      border: 1px solid var(--glass-border);
      border-radius: var(--radius-lg); overflow: hidden;
      transition: transform var(--transition), box-shadow var(--transition), border-color var(--transition);
      height: 100%;
    }
    .room-card:hover { transform:translateY(-5px); box-shadow:0 20px 60px rgba(0,0,0,0.6); border-color:var(--gold); }
    .room-card-img-placeholder {
      width:100%; height:160px;
      display:flex; align-items:center; justify-content:center;
      font-size:2.5rem; color:var(--gold);
    }
    .room-icon-standard { background:linear-gradient(135deg,#1a3a56,#0e2035); }
    .room-icon-deluxe   { background:linear-gradient(135deg,#0e2a40,#152c48); }
    .room-icon-suite    { background:linear-gradient(135deg,#1e1228,#120d22); }
    .room-card-body { padding:1.25rem 1.4rem 1.6rem; }
    .room-card-body h6 { font-family:'Playfair Display',serif; font-size:1.05rem; font-weight:600; color:var(--ivory); margin-bottom:0.2rem; }
    .room-price { font-family:'Playfair Display',serif; font-size:1.5rem; font-weight:700; color:var(--gold); display:block; margin:0.45rem 0 0.3rem; }
    .room-meta  { font-size:0.76rem; color:var(--muted); line-height:1.5; }

    /* ── ANIMATIONS ── */
    @keyframes fadeInUp { from { opacity:0; transform:translateY(24px); } to { opacity:1; transform:translateY(0); } }
    .stat-card  { animation: fadeInUp 0.5s ease both; }
    .quick-card { animation: fadeInUp 0.5s ease both; }
    .room-card  { animation: fadeInUp 0.6s ease both; }

    @media (max-width:768px) {
      .dashboard-hero { padding:2.5rem 1rem 2rem; }
      .dashboard-body { padding:1.5rem 1rem 3rem; }
      .stat-value     { font-size:1.9rem; }
      .rooms-section-inner { padding:1.8rem 1rem; }
    }
  </style>
</head>
<body>

<!-- ══ NAVBAR ══════════════════════════════════════════════════════════════ -->
<nav class="navbar navbar-expand-lg luxury-nav">
  <div class="container-fluid px-3">
    <a class="navbar-brand" href="<%= ctx %>/dashboard">
      <span class="brand-icon"><i class="fas fa-umbrella-beach"></i></span>
      Ocean View Resort
    </a>
    <button class="navbar-toggler border-0" type="button"
            data-bs-toggle="collapse" data-bs-target="#navMenu"
            style="color:var(--muted);">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navMenu">
      <ul class="navbar-nav me-auto gap-1">
        <li class="nav-item">
          <a class="nav-link active" href="<%= ctx %>/dashboard">
            <i class="fas fa-tachometer-alt me-1"></i>Dashboard
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="<%= ctx %>/reservation?action=add">
            <i class="fas fa-plus-circle me-1"></i>New Reservation
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="<%= ctx %>/reservation?action=view">
            <i class="fas fa-search me-1"></i>View Reservation
          </a>
        </li>
        <% if (isAdmin) { %>
        <li class="nav-item">
          <a class="nav-link" href="<%= ctx %>/report">
            <i class="fas fa-chart-bar me-1"></i>Reports
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="<%= ctx %>/staff">
            <i class="fas fa-users-cog me-1"></i>Manage Staff
          </a>
        </li>
        <% } %>
        <li class="nav-item">
          <a class="nav-link" href="<%= ctx %>/help">
            <i class="fas fa-question-circle me-1"></i>Help
          </a>
        </li>
      </ul>
      <ul class="navbar-nav ms-auto align-items-center gap-2">
        <li class="nav-item">
          <%-- FIX: use pre-computed string variable instead of inline ternary with quotes --%>
          <span class="<%= roleBadgeClass %>">
            <i class="fas <%= roleIcon %> me-1"></i><%= role %>
          </span>
        </li>
        <li class="nav-item dropdown">
          <a class="nav-link nav-user-btn dropdown-toggle" href="#" data-bs-toggle="dropdown">
            <i class="fas fa-user-circle me-1"></i><%= user %>
          </a>
          <ul class="dropdown-menu dropdown-menu-end luxury-dropdown">
            <li>
              <span class="dropdown-item-text text-muted small">
                Signed in as <strong><%= user %></strong>
              </span>
            </li>
            <li><hr class="dropdown-divider"/></li>
            <li>
              <a class="dropdown-item text-danger" href="<%= ctx %>/logout">
                <i class="fas fa-sign-out-alt me-2"></i>Logout
              </a>
            </li>
          </ul>
        </li>
      </ul>
    </div>
  </div>
</nav>

<!-- ══ HERO ════════════════════════════════════════════════════════════════ -->
<div class="dashboard-hero" id="dashHero">
  <div class="hero-content container-fluid px-3 d-flex justify-content-between align-items-center flex-wrap gap-3">
    <div>
      <h2><span>Dashboard</span></h2>
      <p class="hero-sub">
        Welcome back, <strong><%= user %></strong>! &ensp;
        <%-- FIX: use pre-computed variable here too --%>
        <span class="<%= roleBadgeClass %>">
          <i class="fas <%= roleIcon %> me-1"></i><%= role %>
        </span>
      </p>
    </div>
    <a href="<%= ctx %>/reservation?action=add" class="btn-gold">
      <i class="fas fa-plus"></i>New Reservation
    </a>
  </div>
</div>

<!-- ══ MAIN BODY ════════════════════════════════════════════════════════════ -->
<div class="dashboard-body">
  <div class="container-fluid px-2">

    <!-- ══ ADMIN STATS ══════════════════════════════════════════════════════ -->
    <% if (isAdmin) { %>
    <div class="mb-2">
      <span class="section-label">Overview</span>
      <h3 class="section-title">At a Glance</h3>
    </div>
    <div class="row g-4 mb-5">
      <div class="col-md-3 col-sm-6">
        <div class="card border-0 stat-card accent-blue h-100">
          <div class="card-body d-flex align-items-center gap-3">
            <div class="stat-icon-wrap blue"><i class="fas fa-calendar-check"></i></div>
            <div>
              <div class="stat-label">Total Reservations</div>
              <div class="stat-value"><%= total %></div>
            </div>
          </div>
        </div>
      </div>
      <div class="col-md-3 col-sm-6">
        <div class="card border-0 stat-card accent-green h-100">
          <div class="card-body d-flex align-items-center gap-3">
            <div class="stat-icon-wrap green"><i class="fas fa-money-bill-wave"></i></div>
            <div>
              <div class="stat-label">Total Income</div>
              <div class="stat-value stat-value-sm text-gold">
                LKR <%= income != null ? String.format("%,.2f", income) : "0.00" %>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="col-md-3 col-sm-6">
        <div class="card border-0 stat-card accent-gold h-100">
          <div class="card-body d-flex align-items-center gap-3">
            <div class="stat-icon-wrap gold"><i class="fas fa-door-open"></i></div>
            <div>
              <div class="stat-label">Active Reservations</div>
              <div class="stat-value text-gold"><%= active %></div>
            </div>
          </div>
        </div>
      </div>
      <div class="col-md-3 col-sm-6">
        <a href="<%= ctx %>/staff" class="text-decoration-none">
          <div class="card border-0 stat-card accent-purple h-100">
            <div class="card-body d-flex align-items-center gap-3">
              <div class="stat-icon-wrap purple"><i class="fas fa-users"></i></div>
              <div>
                <div class="stat-label">Manage Staff</div>
                <div class="stat-value stat-value-sm" style="color:#c39bd3;">Click to manage</div>
              </div>
            </div>
          </div>
        </a>
      </div>
    </div>

    <!-- Admin Quick Actions -->
    <div class="mb-2">
      <span class="section-label">Operations</span>
      <h3 class="section-title">Admin Quick Actions</h3>
    </div>
    <div class="row g-4 mb-2">
      <div class="col-md-3 col-sm-6">
        <a href="<%= ctx %>/reservation?action=add" class="text-decoration-none d-block h-100">
          <div class="card border-0 quick-card h-100">
            <div class="q-icon blue"><i class="fas fa-plus-circle fa-lg"></i></div>
            <h6>New Reservation</h6><p>Create guest reservation</p>
          </div>
        </a>
      </div>
      <div class="col-md-3 col-sm-6">
        <a href="<%= ctx %>/reservation?action=view" class="text-decoration-none d-block h-100">
          <div class="card border-0 quick-card h-100">
            <div class="q-icon teal"><i class="fas fa-search fa-lg"></i></div>
            <h6>View Reservation</h6><p>Search by ID</p>
          </div>
        </a>
      </div>
      <div class="col-md-3 col-sm-6">
        <a href="<%= ctx %>/report" class="text-decoration-none d-block h-100">
          <div class="card border-0 quick-card h-100">
            <div class="q-icon green"><i class="fas fa-chart-bar fa-lg"></i></div>
            <h6>Reports</h6><p>Income &amp; analytics</p>
          </div>
        </a>
      </div>
      <div class="col-md-3 col-sm-6">
        <a href="<%= ctx %>/staff" class="text-decoration-none d-block h-100">
          <div class="card border-0 quick-card h-100">
            <div class="q-icon gold"><i class="fas fa-users-cog fa-lg"></i></div>
            <h6>Manage Staff</h6><p>Add / remove staff</p>
          </div>
        </a>
      </div>
    </div>
    <% } %>

    <!-- ══ STAFF STATS ══════════════════════════════════════════════════════ -->
    <% if (!isAdmin) { %>
    <div class="mb-2">
      <span class="section-label">Overview</span>
      <h3 class="section-title">At a Glance</h3>
    </div>
    <div class="row g-4 mb-5">
      <div class="col-md-4">
        <div class="card border-0 stat-card accent-blue h-100">
          <div class="card-body d-flex align-items-center gap-3">
            <div class="stat-icon-wrap blue"><i class="fas fa-calendar-check"></i></div>
            <div>
              <div class="stat-label">Total Reservations</div>
              <div class="stat-value"><%= total %></div>
            </div>
          </div>
        </div>
      </div>
      <div class="col-md-4">
        <div class="card border-0 stat-card accent-gold h-100">
          <div class="card-body d-flex align-items-center gap-3">
            <div class="stat-icon-wrap gold"><i class="fas fa-door-open"></i></div>
            <div>
              <div class="stat-label">Active Reservations</div>
              <div class="stat-value text-gold"><%= active %></div>
            </div>
          </div>
        </div>
      </div>
      <div class="col-md-4">
        <div class="card border-0 stat-card accent-green h-100">
          <div class="card-body d-flex align-items-center gap-3">
            <div class="stat-icon-wrap green"><i class="fas fa-concierge-bell"></i></div>
            <div>
              <div class="stat-label">Your Role</div>
              <div class="stat-value stat-value-sm" style="color:#52d68a;">Front Desk Staff</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Staff Quick Actions -->
    <div class="mb-2">
      <span class="section-label">Operations</span>
      <h3 class="section-title">Quick Actions</h3>
    </div>
    <div class="row g-4 mb-5">
      <div class="col-md-4 col-sm-6">
        <a href="<%= ctx %>/reservation?action=add" class="text-decoration-none d-block h-100">
          <div class="card border-0 quick-card h-100">
            <div class="q-icon blue"><i class="fas fa-plus-circle fa-lg"></i></div>
            <h6>New Reservation</h6><p>Create guest reservation</p>
          </div>
        </a>
      </div>
      <div class="col-md-4 col-sm-6">
        <a href="<%= ctx %>/reservation?action=view" class="text-decoration-none d-block h-100">
          <div class="card border-0 quick-card h-100">
            <div class="q-icon teal"><i class="fas fa-search fa-lg"></i></div>
            <h6>View Reservation</h6><p>Search by ID</p>
          </div>
        </a>
      </div>
      <div class="col-md-4 col-sm-6">
        <a href="<%= ctx %>/help" class="text-decoration-none d-block h-100">
          <div class="card border-0 quick-card h-100">
            <div class="q-icon gold"><i class="fas fa-question-circle fa-lg"></i></div>
            <h6>Help</h6><p>User guide</p>
          </div>
        </a>
      </div>
    </div>

    <div class="luxury-alert mb-4">
      <i class="fas fa-info-circle me-2" style="color:#20c9cb;"></i>
      <strong>Staff Access:</strong> You can add and view reservations and print bills.
      For reports and staff management, please contact your administrator.
    </div>
    <% } %>

    <!-- ══ ROOM TYPES ══════════════════════════════════════════════════════ -->
    <div class="rooms-section" id="roomsSection">
      <div class="rooms-parallax-bg" id="roomsBg"></div>
      <div class="rooms-section-inner">
        <div class="rooms-section-header">
          <span class="section-label">Accommodations</span>
          <h3 class="section-title">Room Types &amp; Pricing</h3>
        </div>
        <div class="row g-4 justify-content-center">
          <div class="col-md-4 col-sm-10">
            <div class="room-card">
              <div class="room-card-img-placeholder room-icon-standard">
                <i class="fas fa-bed"></i>
              </div>
              <div class="room-card-body">
                <h6>Standard Room</h6>
                <span class="room-price">LKR 10,000
                  <small style="font-size:0.6em;color:var(--muted);font-family:'Inter',sans-serif;font-weight:400;"> / night</small>
                </span>
                <p class="room-meta"><i class="fas fa-leaf me-1" style="color:var(--gold);"></i>Garden view &nbsp;·&nbsp; AC &nbsp;·&nbsp; TV &nbsp;·&nbsp; En-suite</p>
              </div>
            </div>
          </div>
          <div class="col-md-4 col-sm-10">
            <div class="room-card">
              <div class="room-card-img-placeholder room-icon-deluxe">
                <i class="fas fa-star"></i>
              </div>
              <div class="room-card-body">
                <h6>Deluxe Room</h6>
                <span class="room-price">LKR 15,000
                  <small style="font-size:0.6em;color:var(--muted);font-family:'Inter',sans-serif;font-weight:400;"> / night</small>
                </span>
                <p class="room-meta"><i class="fas fa-water me-1" style="color:var(--gold);"></i>Ocean view &nbsp;·&nbsp; Balcony &nbsp;·&nbsp; Mini-bar</p>
              </div>
            </div>
          </div>
          <div class="col-md-4 col-sm-10">
            <div class="room-card">
              <div class="room-card-img-placeholder room-icon-suite">
                <i class="fas fa-crown"></i>
              </div>
              <div class="room-card-body">
                <h6>Suite</h6>
                <span class="room-price">LKR 25,000
                  <small style="font-size:0.6em;color:var(--muted);font-family:'Inter',sans-serif;font-weight:400;"> / night</small>
                </span>
                <p class="room-meta"><i class="fas fa-concierge-bell me-1" style="color:var(--gold);"></i>Luxury &nbsp;·&nbsp; Jacuzzi &nbsp;·&nbsp; Butler service</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

  </div><!-- /container-fluid -->
</div><!-- /dashboard-body -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
  /* ── Parallax ── */
  (function() {
    const roomsBg = document.getElementById('roomsBg');
    function onScroll() {
      if (roomsBg) {
        const rect   = roomsBg.parentElement.getBoundingClientRect();
        const offset = ((rect.top + rect.height / 2) / window.innerHeight - 0.5) * 40;
        roomsBg.style.transform = 'translateY(' + offset + 'px)';
      }
    }
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  })();

  /* ── Intersection Observer: fade-in cards ── */
  (function() {
    const cards = document.querySelectorAll('.stat-card, .quick-card, .room-card');
    const io = new IntersectionObserver(function(entries) {
      entries.forEach(function(e) {
        if (e.isIntersecting) {
          e.target.style.opacity = '1';
        }
      });
    }, { threshold: 0.15 });
    cards.forEach(function(c) {
      c.style.opacity = '0';
      io.observe(c);
    });
  })();
</script>
</body>
</html>
