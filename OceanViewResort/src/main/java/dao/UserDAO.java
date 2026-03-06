package dao;

import model.OtpRecord;
import model.User;
import java.time.LocalDateTime;
import java.util.List;

/**
 * UserDAO – interface for all user and OTP operations.
 */
public interface UserDAO {

    // ── Auth ──────────────────────────────────────────────────────────────────
    User    authenticate(String username, String password);
    User    findByEmail(String email);
    User    getUserByUsername(String username);       // ← ADDED (used by PasswordResetServlet)

    // ── OTP / Password Reset (used by ForgotPasswordServlet via OtpService) ───
    boolean   saveOtp(int userId, String email, String otpCode, LocalDateTime expiresAt);
    OtpRecord verifyOtp(String email, String otpCode);
    boolean   markOtpUsed(int otpId);

    // ── OTP / Password Reset (used by PasswordResetServlet) ───────────────────
    boolean saveOTP(int userId, String otpCode, int expiryMinutes);  // ← ADDED
    boolean verifyOTP(int userId, String otpCode);                   // ← ADDED
    boolean markOTPUsed(int userId, String otpCode);                 // ← ADDED

    // ── Password & Email ──────────────────────────────────────────────────────
    boolean updatePassword(int userId, String newPassword);
    boolean updateEmail(int userId, String email);                   // ← ADDED

    // ── Staff Management ──────────────────────────────────────────────────────
    boolean    registerStaff(String username, String password);
    List<User> getAllStaff();
    List<User> getAllUsers();
    boolean    deleteUser(int id);
    boolean    usernameExists(String username);
}
