package service;

import dao.UserDAO;
import dao.UserDAOImpl;
import model.OtpRecord;
import model.User;

import java.security.SecureRandom;
import java.time.LocalDateTime;

/**
 * OtpService – Business logic for the OTP password-reset flow.
 *
 * Flow:
 *   Step 1: Admin enters email → 

 *   Step 2: Admin enters OTP  → verifyOtp()
 *   Step 3: Admin enters new password → resetPassword()
 */
public class OtpService {

    private final UserDAO userDAO = new UserDAOImpl();
    private static final int OTP_EXPIRY_MINUTES = 10;

    // ── Step 1: Generate OTP, save to DB, send email ──────────────────────────
    /**
     * @return "OK" on success, or an error message string
     */
    public String generateAndSendOtp(String email) {
        if (email == null || email.trim().isEmpty()) {
            return "Please enter your email address.";
        }

        // Find the user by email — ADMIN only for security
        User user = userDAO.findByEmail(email.trim().toLowerCase());
        if (user == null) {
            // Generic message to prevent email enumeration attacks
            return "User not found for email: " + email;
        }
        if (!user.isAdmin()) {
            return "Password reset via OTP is only available for Admin accounts.";
        }

        // Generate a 6-digit OTP
        String otp = generateOtp();

        // Set expiry: now + 10 minutes
        LocalDateTime expiresAt = LocalDateTime.now(java.time.ZoneId.of("Asia/Colombo")).plusMinutes(OTP_EXPIRY_MINUTES);

        // Save to database
        boolean saved = userDAO.saveOtp(user.getId(), email.trim().toLowerCase(), otp, expiresAt);
        if (!saved) {
            return "Database error. Please try again.";
        }

        // Send email
        boolean sent = EmailService.sendOtpEmail(email, otp);
        if (!sent) {
            return "Failed to send OTP email. Please check mail configuration or try again.";
        }

        return "OK";
    }

    // ── Step 2: Verify OTP ────────────────────────────────────────────────────
    /**
     * @return OtpRecord if valid, null if invalid/expired
     */
    public OtpRecord verifyOtp(String email, String otpCode) {
        if (email == null || otpCode == null) return null;
        return userDAO.verifyOtp(email.trim().toLowerCase(), otpCode.trim());
    }

    // ── Step 3: Reset Password ────────────────────────────────────────────────
    /**
     * @return "OK" on success, or error message
     */
    public String resetPassword(String email, String otpCode,
                                String newPassword, String confirmPassword) {
        // Validate passwords
        if (newPassword == null || newPassword.length() < 6) {
            return "New password must be at least 6 characters.";
        }
        if (!newPassword.equals(confirmPassword)) {
            return "Passwords do not match.";
        }

        // Verify OTP one more time
        OtpRecord otp = userDAO.verifyOtp(email.trim().toLowerCase(), otpCode.trim());
        if (otp == null) {
            return "OTP is invalid or has expired. Please request a new OTP.";
        }

        // Update password
        boolean updated = userDAO.updatePassword(otp.getUserId(), newPassword);
        if (!updated) {
            return "Database error. Could not update password.";
        }

        // Mark OTP as used so it can't be reused
        userDAO.markOtpUsed(otp.getId());
        return "OK";
    }

    // ── Generate 6-digit numeric OTP ─────────────────────────────────────────
    private String generateOtp() {
        SecureRandom random = new SecureRandom();
        int otp = 100000 + random.nextInt(900000); // always 6 digits
        return String.valueOf(otp);
    }
}
