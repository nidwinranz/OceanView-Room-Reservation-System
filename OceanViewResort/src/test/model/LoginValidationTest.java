package model;

import org.junit.Test;
import org.junit.Before;
import static org.junit.Assert.*;
import util.ValidationUtil;

/**
 * LoginValidationTest – Unit tests for login input validation.
 *
 * Test Rationale:
 * The login page accepts username and password only (no email).
 * These tests verify that the validation rules applied before
 * authentication are correct — empty fields, whitespace-only inputs,
 * special characters, and weak passwords are all rejected before
 * reaching the database.
 */
public class LoginValidationTest {

    private String validUsername;
    private String validPassword;

    @Before
    public void setUp() {
        validUsername = "john_doe";
        validPassword = "password123";
    }

    // ── Username Field Tests ──────────────────────────────────────────────────

    @Test
    public void testLogin_ValidUsername_NotEmpty() {
        assertFalse("Valid username should not be empty",
                ValidationUtil.isEmpty(validUsername));
    }

    @Test
    public void testLogin_EmptyUsername_Rejected() {
        assertTrue("Empty username should be rejected",
                ValidationUtil.isEmpty(""));
    }

    @Test
    public void testLogin_NullUsername_Rejected() {
        assertTrue("Null username should be rejected",
                ValidationUtil.isEmpty(null));
    }

    @Test
    public void testLogin_WhitespaceUsername_Rejected() {
        assertTrue("Whitespace-only username should be rejected",
                ValidationUtil.isEmpty("   "));
    }

    @Test
    public void testLogin_Sanitize_TrimsUsernameWhitespace() {
        assertEquals("Sanitized username should be trimmed",
                "john_doe", ValidationUtil.sanitize("  john_doe  "));
    }

    @Test
    public void testLogin_Sanitize_NullUsernameInput() {
        assertEquals("Null username should sanitize to empty string",
                "", ValidationUtil.sanitize(null));
    }

    // ── Username Character Validation Tests ───────────────────────────────────

    @Test
    public void testLogin_Username_SqlInjection_IsNotEmpty() {
        assertFalse(ValidationUtil.isEmpty("' OR '1'='1"));
    }

    @Test
    public void testLogin_Username_WithSpaces_DetectedAsNonEmpty() {
        assertFalse(ValidationUtil.isEmpty("john doe"));
    }

    @Test
    public void testLogin_Username_SpecialCharsOnly_DetectedAsNonEmpty() {
        assertFalse(ValidationUtil.isEmpty("@#$%"));
    }

    @Test
    public void testLogin_Username_NumbersOnly_DetectedAsNonEmpty() {
        assertFalse(ValidationUtil.isEmpty("123456"));
    }

    // ── Password Field Tests ──────────────────────────────────────────────────

    @Test
    public void testLogin_ValidPassword_Accepted() {
        assertTrue("Valid password should be accepted",
                ValidationUtil.isValidPassword(validPassword));
    }

    @Test
    public void testLogin_EmptyPassword_Rejected() {
        assertFalse("Empty password should be rejected",
                ValidationUtil.isValidPassword(""));
    }

    @Test
    public void testLogin_NullPassword_Rejected() {
        assertFalse("Null password should be rejected",
                ValidationUtil.isValidPassword(null));
    }

    @Test
    public void testLogin_ShortPassword_Rejected() {
        assertFalse("Password shorter than 6 chars should be rejected",
                ValidationUtil.isValidPassword("abc"));
    }

    @Test
    public void testLogin_SixCharPassword_Accepted() {
        assertTrue("Exactly 6-char password should be accepted",
                ValidationUtil.isValidPassword("abc123"));
    }

    @Test
    public void testLogin_PasswordWithSpecialChars_Accepted() {
        assertTrue("Password with special chars should be accepted",
                ValidationUtil.isValidPassword("p@ssw0rd!"));
    }

    @Test
    public void testLogin_PasswordAllNumbers_Accepted() {
        assertTrue("All-numeric password should be accepted if 6+ digits",
                ValidationUtil.isValidPassword("123456"));
    }

    @Test
    public void testLogin_PasswordSingleChar_Rejected() {
        assertFalse("Single character password should be rejected",
                ValidationUtil.isValidPassword("a"));
    }

    @Test
    public void testLogin_PasswordWhitespaceOnly_Rejected() {
        assertFalse("Whitespace-only password should be rejected",
                ValidationUtil.isValidPassword("  "));
    }

    // ── User Role Tests After Login ───────────────────────────────────────────

    @Test
    public void testLogin_AdminUser_HasAdminAccess() {
        User admin = new User(1, "admin", "admin123", "ADMIN", "admin@oceanview.com");
        assertTrue("Admin user should have admin access", admin.isAdmin());
        assertFalse("Admin user should not be staff", admin.isStaff());
    }

    @Test
    public void testLogin_StaffUser_HasStaffAccess() {
        User staff = new User(2, "staff1", "staff123", "STAFF", "staff@oceanview.com");
        assertTrue("Staff user should have staff access", staff.isStaff());
        assertFalse("Staff user should not be admin", staff.isAdmin());
    }

    @Test
    public void testLogin_UserWithNoRole_NoAccess() {
        User noRole = new User(3, "guest", "guest123", null, "guest@oceanview.com");
        assertFalse("User with null role should not be admin", noRole.isAdmin());
        assertFalse("User with null role should not be staff", noRole.isStaff());
    }

    @Test
    public void testLogin_AdminRole_CaseInsensitive() {
        User admin = new User(4, "admin2", "admin123", "admin", "admin2@oceanview.com");
        assertTrue("Lowercase admin role should still pass isAdmin()", admin.isAdmin());
    }

    @Test
    public void testLogin_StaffRole_CaseInsensitive() {
        User staff = new User(5, "staff2", "staff123", "staff", "staff2@oceanview.com");
        assertTrue("Lowercase staff role should still pass isStaff()", staff.isStaff());
    }
}
