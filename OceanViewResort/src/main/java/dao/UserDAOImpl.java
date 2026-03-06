package dao;

import model.OtpRecord;
import model.User;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * UserDAOImpl – concrete implementation with OTP + password reset support.
 */
public class UserDAOImpl implements UserDAO {

    // ── Helper: map ResultSet → User ─────────────────────────────────────────
    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setRole(rs.getString("role"));
        u.setEmail(rs.getString("email"));
        return u;
    }

    // ── Authenticate ──────────────────────────────────────────────────────────
    @Override
    public User authenticate(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[UserDAO] authenticate: " + e.getMessage());
        }
        return null;
    }

    // ── Find User by Email ────────────────────────────────────────────────────
    @Override
    public User findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email.trim().toLowerCase());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[UserDAO] findByEmail: " + e.getMessage());
        }
        return null;
    }

    // ── Get User by Username ──────────────────────────────────────────────────
    // Used by PasswordResetServlet to get the logged-in admin's details
    @Override
    public User getUserByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[UserDAO] getUserByUsername: " + e.getMessage());
        }
        return null;
    }

    // ── Update Email ──────────────────────────────────────────────────────────
    // Used by PasswordResetServlet when admin enters/updates their email
    @Override
    public boolean updateEmail(int userId, String email) {
        String sql = "UPDATE users SET email = ? WHERE id = ?";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email.trim().toLowerCase());
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO] updateEmail: " + e.getMessage());
        }
        return false;
    }

    // ── Save OTP (used by ForgotPasswordServlet via OtpService) ──────────────
    @Override
    public boolean saveOtp(int userId, String email, String otpCode, LocalDateTime expiresAt) {
        String invalidate = "UPDATE password_reset_otp SET is_used=1 WHERE user_id=? AND is_used=0";
        String insert     = "INSERT INTO password_reset_otp (user_id,email,otp_code,expires_at) VALUES (?,?,?,?)";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps1 = conn.prepareStatement(invalidate);
            ps1.setInt(1, userId);
            ps1.executeUpdate();

            PreparedStatement ps2 = conn.prepareStatement(insert);
            ps2.setInt(1, userId);
            ps2.setString(2, email);
            ps2.setString(3, otpCode);
            ps2.setTimestamp(4, new Timestamp(System.currentTimeMillis() + (10 * 60 * 1000L)));
            return ps2.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO] saveOtp: " + e.getMessage());
        }
        return false;
    }

    // ── Save OTP (used by PasswordResetServlet) ───────────────────────────────
    // Simpler version: takes userId, otpCode, and expiry in minutes
    @Override
    public boolean saveOTP(int userId, String otpCode, int expiryMinutes) {
        String invalidate = "UPDATE password_reset_otp SET is_used=1 WHERE user_id=? AND is_used=0";
        String insert     = "INSERT INTO password_reset_otp (user_id, email, otp_code, expires_at) " +
                            "VALUES (?, (SELECT LOWER(email) FROM users WHERE id=?), ?, ?)";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps1 = conn.prepareStatement(invalidate);
            ps1.setInt(1, userId);
            ps1.executeUpdate();

            LocalDateTime expiresAt = LocalDateTime.now().plusMinutes(expiryMinutes);
            PreparedStatement ps2 = conn.prepareStatement(insert);
            ps2.setInt(1, userId);
            ps2.setInt(2, userId);
            ps2.setString(3, otpCode);
            ps2.setTimestamp(4, new Timestamp(System.currentTimeMillis() + (expiryMinutes * 60 * 1000L)));
            return ps2.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO] saveOTP: " + e.getMessage());
        }
        return false;
    }

    // ── Verify OTP by email + code (used by ForgotPasswordServlet) ───────────
    @Override
    public OtpRecord verifyOtp(String email, String otpCode) {
        String sql = "SELECT * FROM password_reset_otp " +
                "WHERE email=? AND otp_code=? AND is_used=0 " +
                "AND expires_at > NOW() " +
                "ORDER BY created_at DESC LIMIT 1";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, otpCode);
            System.out.println(">>> SQL email=[" + email + "] otp=[" + otpCode + "]");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                OtpRecord otp = new OtpRecord();
                otp.setId(rs.getInt("id"));
                otp.setUserId(rs.getInt("user_id"));
                otp.setEmail(rs.getString("email"));
                otp.setOtpCode(rs.getString("otp_code"));
                otp.setExpiresAt(rs.getTimestamp("expires_at").toLocalDateTime());
                otp.setUsed(rs.getBoolean("is_used"));
                System.out.println(">>> OTP verified successfully!");
                return otp;
            }
            System.out.println(">>> OTP not found in DB!");
        } catch (SQLException e) {
            System.err.println("[UserDAO] verifyOtp: " + e.getMessage());
        }
        return null;
    }

    // ── Verify OTP by userId + code (used by PasswordResetServlet) ───────────
    @Override
    public boolean verifyOTP(int userId, String otpCode) {
    	String sql = "SELECT * FROM password_reset_otp " +
                "WHERE user_id=? AND otp_code=? AND is_used=0 " +
                "AND expires_at > DATE_SUB(NOW(), INTERVAL 330 MINUTE) " +
                "ORDER BY created_at DESC LIMIT 1";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, otpCode);
            ResultSet rs = ps.executeQuery();
            return rs.next(); // true = valid OTP found
        } catch (SQLException e) {
            System.err.println("[UserDAO] verifyOTP: " + e.getMessage());
        }
        return false;
    }

    // ── Mark OTP Used by OTP record ID (used by ForgotPasswordServlet) ────────
    @Override
    public boolean markOtpUsed(int otpId) {
        String sql = "UPDATE password_reset_otp SET is_used=1 WHERE id=?";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, otpId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO] markOtpUsed: " + e.getMessage());
        }
        return false;
    }

    // ── Mark OTP Used by userId + code (used by PasswordResetServlet) ─────────
    @Override
    public boolean markOTPUsed(int userId, String otpCode) {
        String sql = "UPDATE password_reset_otp SET is_used=1 WHERE user_id=? AND otp_code=?";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, otpCode);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO] markOTPUsed: " + e.getMessage());
        }
        return false;
    }

    // ── Update Password ───────────────────────────────────────────────────────
    @Override
    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password=? WHERE id=?";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, newPassword);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO] updatePassword: " + e.getMessage());
        }
        return false;
    }

    // ── Register Staff ────────────────────────────────────────────────────────
    @Override
    public boolean registerStaff(String username, String password) {
        String sql = "INSERT INTO users (username, password, role) VALUES (?, ?, 'STAFF')";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO] registerStaff: " + e.getMessage());
            return false;
        }
    }

    // ── Get All Staff ─────────────────────────────────────────────────────────
    @Override
    public List<User> getAllStaff() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role='STAFF' ORDER BY id";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery(sql);
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[UserDAO] getAllStaff: " + e.getMessage());
        }
        return list;
    }

    // ── Get All Users ─────────────────────────────────────────────────────────
    @Override
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY role, id";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            Statement st = conn.createStatement();
            ResultSet rs = st.executeQuery(sql);
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[UserDAO] getAllUsers: " + e.getMessage());
        }
        return list;
    }

    // ── Delete User ───────────────────────────────────────────────────────────
    @Override
    public boolean deleteUser(int id) {
        String sql = "DELETE FROM users WHERE id=? AND role='STAFF'";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[UserDAO] deleteUser: " + e.getMessage());
            return false;
        }
    }

    // ── Username Exists ───────────────────────────────────────────────────────
    @Override
    public boolean usernameExists(String username) {
        String sql = "SELECT 1 FROM users WHERE username=?";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            return ps.executeQuery().next();
        } catch (SQLException e) {
            System.err.println("[UserDAO] usernameExists: " + e.getMessage());
        }
        return false;
    }
}
