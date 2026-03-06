package servlet;

import model.OtpRecord;
import service.OtpService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * ForgotPasswordServlet
 * ──────────────────────
 * Handles the 3-step OTP password reset flow:
 *
 * GET  /forgot-password              → Show email input form (Step 1)
 * POST /forgot-password?step=email   → Send OTP to email
 * POST /forgot-password?step=verify  → Verify OTP (Step 2)
 * POST /forgot-password?step=reset   → Save new password (Step 3)
 */
@WebServlet(name = "ForgotPasswordServlet", urlPatterns = "/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private final OtpService otpService = new OtpService();

    // ── GET – show the forgot password page ───────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/jsp/forgotPassword.jsp").forward(req, resp);
    }

    // ── POST – handle each step ───────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String step = req.getParameter("step");
        if (step == null) step = "email";

        switch (step) {
            case "email":  handleEmailStep(req, resp);  break;
            case "verify": handleVerifyStep(req, resp); break;
            case "reset":  handleResetStep(req, resp);  break;
            default:       resp.sendRedirect(req.getContextPath() + "/forgot-password");
        }
    }

    // ── STEP 1: Receive email, generate & send OTP ────────────────────────────
    private void handleEmailStep(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String result = otpService.generateAndSendOtp(email);

        if ("OK".equals(result)) {
            // Move to OTP entry screen
            req.setAttribute("step",          "verify");
            req.setAttribute("email",         email.trim().toLowerCase());
            req.setAttribute("successMsg",    "OTP sent! Check your email inbox.");
        } else {
            // Show error on email form but use generic message for security
            req.setAttribute("step",  "email");
            req.setAttribute("error", result);
            req.setAttribute("email", email);
        }
        req.getRequestDispatcher("/jsp/forgotPassword.jsp").forward(req, resp);
    }

    // ── STEP 2: Verify OTP ────────────────────────────────────────────────────
    private void handleVerifyStep(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email   = req.getParameter("email");
        String otpCode = req.getParameter("otpCode");
        
        System.out.println(">>> VERIFY: email=[" + email + "] otp=[" + otpCode + "]");
        OtpRecord otp = otpService.verifyOtp(email, otpCode);

        if (otp != null) {
            // OTP valid → show new password form
            req.setAttribute("step",    "reset");
            req.setAttribute("email",   email);
            req.setAttribute("otpCode", otpCode);
        } else {
            // Invalid OTP → back to verify screen
            req.setAttribute("step",    "verify");
            req.setAttribute("email",   email);
            req.setAttribute("error",   "Invalid or expired OTP. Please try again.");
        }
        req.getRequestDispatcher("/jsp/forgotPassword.jsp").forward(req, resp);
    }

    // ── STEP 3: Reset Password ────────────────────────────────────────────────
    private void handleResetStep(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email           = req.getParameter("email");
        String otpCode         = req.getParameter("otpCode");
        String newPassword     = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        String result = otpService.resetPassword(email, otpCode, newPassword, confirmPassword);

        if ("OK".equals(result)) {
            // Success → redirect to login with success message
            resp.sendRedirect(req.getContextPath() + "/login?msg=reset_success");
        } else {
            // Error → back to reset form
            req.setAttribute("step",    "reset");
            req.setAttribute("email",   email);
            req.setAttribute("otpCode", otpCode);
            req.setAttribute("error",   result);
            req.getRequestDispatcher("/jsp/forgotPassword.jsp").forward(req, resp);
        }
    }
}
