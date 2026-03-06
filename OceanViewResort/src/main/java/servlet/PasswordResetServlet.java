package servlet;

import dao.UserDAO;
import dao.UserDAOImpl;
import model.User;
import service.EmailService;
import util.AuthGuard;
import util.OTPGenerator;
import util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * PasswordResetServlet – 3-step OTP password reset flow.
 * ────────────────────────────────────────────────────────
 * STEP 1: GET  /change-password          → show "enter email" form
 * STEP 2: POST /change-password?step=otp → send OTP to email
 * STEP 3: POST /change-password?step=verify → verify OTP, show new password form
 * STEP 4: POST /change-password?step=reset  → save new password
 *
 * ADMIN ONLY – staff cannot change passwords via OTP.
 */
@WebServlet(name = "PasswordResetServlet", urlPatterns = "/change-password")
public class PasswordResetServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAOImpl();
    private static final int OTP_EXPIRY_MINUTES = 10;

    // ── GET – Show Step 1: Email form ─────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!AuthGuard.isAdmin(req, resp)) return;

        // Pre-fill email from session user's profile
        String username = AuthGuard.getUsername(req);
        User user = userDAO.getUserByUsername(username);
        if (user != null && user.getEmail() != null) {
            req.setAttribute("savedEmail", user.getEmail());
        }

        req.setAttribute("step", "email");
        req.getRequestDispatcher("/jsp/changePassword.jsp").forward(req, resp);
    }

    // ── POST – Handle all steps ───────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!AuthGuard.isAdmin(req, resp)) return;

        String step = req.getParameter("step");
        if (step == null) step = "otp";

        switch (step) {
            case "otp":    handleSendOTP(req, resp);     break;
            case "verify": handleVerifyOTP(req, resp);   break;
            case "reset":  handleResetPassword(req, resp); break;
            default:       resp.sendRedirect(req.getContextPath() + "/change-password");
        }
    }

    // ── STEP 2: Send OTP to email ─────────────────────────────────────────────
    private void handleSendOTP(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email    = ValidationUtil.sanitize(req.getParameter("email"));
        String username = AuthGuard.getUsername(req);
        User   user     = userDAO.getUserByUsername(username);

        // Validate email
        if (ValidationUtil.isEmpty(email) || !email.contains("@")) {
            req.setAttribute("step",  "email");
            req.setAttribute("error", "Please enter a valid email address.");
            req.getRequestDispatcher("/jsp/changePassword.jsp").forward(req, resp);
            return;
        }

        if (user == null) {
            req.setAttribute("step",  "email");
            req.setAttribute("error", "Session error. Please log in again.");
            req.getRequestDispatcher("/jsp/changePassword.jsp").forward(req, resp);
            return;
        }

        // Save email to DB if not already set or changed
        if (!email.equals(user.getEmail())) {
            userDAO.updateEmail(user.getId(), email);
        }

        // Generate and save OTP
        String otpCode = OTPGenerator.generate();
        boolean saved  = userDAO.saveOTP(user.getId(), otpCode, OTP_EXPIRY_MINUTES);

        if (!saved) {
            req.setAttribute("step",  "email");
            req.setAttribute("error", "Failed to generate OTP. Please try again.");
            req.getRequestDispatcher("/jsp/changePassword.jsp").forward(req, resp);
            return;
        }

        // Send OTP via email
        boolean sent = EmailService.sendOTPEmail(email, otpCode, username);

        if (sent) {
            // Store in session for verification step
            HttpSession session = req.getSession();
            session.setAttribute("otpEmail",  email);
            session.setAttribute("otpUserId", user.getId());

            req.setAttribute("step",    "otp");
            req.setAttribute("email",   maskEmail(email));
            req.setAttribute("success", "OTP sent! Check your inbox at " + maskEmail(email));
        } else {
            req.setAttribute("step",       "email");
            req.setAttribute("savedEmail", email);
            req.setAttribute("error",
                "Failed to send email. Check your internet connection or email configuration.");
        }

        req.getRequestDispatcher("/jsp/changePassword.jsp").forward(req, resp);
    }

    // ── STEP 3: Verify OTP ────────────────────────────────────────────────────
    private void handleVerifyOTP(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String otp     = req.getParameter("otp");
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("otpUserId") == null) {
            resp.sendRedirect(req.getContextPath() + "/change-password");
            return;
        }

        int    userId = (Integer) session.getAttribute("otpUserId");
        String email  = (String)  session.getAttribute("otpEmail");

        if (ValidationUtil.isEmpty(otp) || otp.length() != 6) {
            req.setAttribute("step",  "otp");
            req.setAttribute("email", maskEmail(email));
            req.setAttribute("error", "Please enter the 6-digit OTP code.");
            req.getRequestDispatcher("/jsp/changePassword.jsp").forward(req, resp);
            return;
        }

        boolean valid = userDAO.verifyOTP(userId, otp);

        if (valid) {
            // OTP is correct – store in session and show new password form
            session.setAttribute("otpVerified", true);
            session.setAttribute("otpCode",     otp);

            req.setAttribute("step", "newpassword");
        } else {
            req.setAttribute("step",  "otp");
            req.setAttribute("email", maskEmail(email));
            req.setAttribute("error", "Invalid or expired OTP. Please try again or request a new one.");
        }

        req.getRequestDispatcher("/jsp/changePassword.jsp").forward(req, resp);
    }

    // ── STEP 4: Save New Password ─────────────────────────────────────────────
    private void handleResetPassword(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // Security check: OTP must have been verified
        if (session == null
                || session.getAttribute("otpVerified") == null
                || !(Boolean) session.getAttribute("otpVerified")) {
            resp.sendRedirect(req.getContextPath() + "/change-password");
            return;
        }

        String newPassword     = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");
        int    userId          = (Integer) session.getAttribute("otpUserId");
        String otpCode         = (String)  session.getAttribute("otpCode");

        // Validate new password
        if (ValidationUtil.isEmpty(newPassword) || newPassword.length() < 6) {
            req.setAttribute("step",  "newpassword");
            req.setAttribute("error", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/jsp/changePassword.jsp").forward(req, resp);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("step",  "newpassword");
            req.setAttribute("error", "Passwords do not match. Please try again.");
            req.getRequestDispatcher("/jsp/changePassword.jsp").forward(req, resp);
            return;
        }

        // Save new password
        boolean updated = userDAO.updatePassword(userId, newPassword);

        if (updated) {
            // Mark OTP as used so it cannot be reused
            userDAO.markOTPUsed(userId, otpCode);

            // Clear OTP-related session data
            session.removeAttribute("otpEmail");
            session.removeAttribute("otpUserId");
            session.removeAttribute("otpVerified");
            session.removeAttribute("otpCode");

            req.setAttribute("step",    "done");
            req.setAttribute("success", "Password changed successfully! Please log in with your new password.");
        } else {
            req.setAttribute("step",  "newpassword");
            req.setAttribute("error", "Failed to update password. Please try again.");
        }

        req.getRequestDispatcher("/jsp/changePassword.jsp").forward(req, resp);
    }

    // ── Helper: mask email for display e.g. ad***@gmail.com ──────────────────
    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) return email;
        String[] parts = email.split("@");
        String   name  = parts[0];
        String   domain = parts[1];
        if (name.length() <= 2) return name + "***@" + domain;
        return name.substring(0, 2) + "***@" + domain;
    }
}
