package model;

import org.junit.Test;
import org.junit.Before;
import static org.junit.Assert.*;

import static org.junit.Assert.*;

/**
 * UserTest – Unit tests for the User model class.
 *
 * Test Rationale:
 * The User model is the core authentication entity. Tests verify that
 * getters/setters work correctly and role-based checks (isAdmin, isStaff)
 * function as expected for access control throughout the application.
 */
public class UserTest {

    private User user;

    @Before
    public void setUp() {
        user = new User(1, "john_doe", "password123", "ADMIN", "john@example.com");
    }

    // ── Constructor Tests ─────────────────────────────────────────────────────

    @Test
    public void testParameterizedConstructor() {
        assertEquals(1, user.getId());
        assertEquals("john_doe", user.getUsername());
        assertEquals("password123", user.getPassword());
        assertEquals("ADMIN", user.getRole());
        assertEquals("john@example.com", user.getEmail());
    }

    @Test
    public void testDefaultConstructor() {
        User emptyUser = new User();
        assertNull(emptyUser.getUsername());
        assertNull(emptyUser.getRole());
    }

    // ── Setter Tests ──────────────────────────────────────────────────────────

    @Test
    public void testSetId() {
        user.setId(99);
        assertEquals(99, user.getId());
    }

    @Test
    public void testSetUsername() {
        user.setUsername("new_user");
        assertEquals("new_user", user.getUsername());
    }

    @Test
    public void testSetPassword() {
        user.setPassword("newpass456");
        assertEquals("newpass456", user.getPassword());
    }

    @Test
    public void testSetEmail() {
        user.setEmail("newemail@test.com");
        assertEquals("newemail@test.com", user.getEmail());
    }

    @Test
    public void testSetRole() {
        user.setRole("STAFF");
        assertEquals("STAFF", user.getRole());
    }

    // ── Role Tests ────────────────────────────────────────────────────────────

    @Test
    public void testIsAdmin_WhenRoleIsAdmin_ReturnsTrue() {
        user.setRole("ADMIN");
        assertTrue(user.isAdmin());
    }

    @Test
    public void testIsAdmin_WhenRoleIsLowercase_ReturnsTrue() {
        user.setRole("admin");
        assertTrue(user.isAdmin());
    }

    @Test
    public void testIsAdmin_WhenRoleIsStaff_ReturnsFalse() {
        user.setRole("STAFF");
        assertFalse(user.isAdmin());
    }

    @Test
    public void testIsStaff_WhenRoleIsStaff_ReturnsTrue() {
        user.setRole("STAFF");
        assertTrue(user.isStaff());
    }

    @Test
    public void testIsStaff_WhenRoleIsAdmin_ReturnsFalse() {
        user.setRole("ADMIN");
        assertFalse(user.isStaff());
    }

    @Test
    public void testIsStaff_WhenRoleIsLowercase_ReturnsTrue() {
        user.setRole("staff");
        assertTrue(user.isStaff());
    }

    @Test
    public void testIsAdmin_WhenRoleIsNull_ReturnsFalse() {
        user.setRole(null);
        assertFalse(user.isAdmin());
    }

    @Test
    public void testIsStaff_WhenRoleIsNull_ReturnsFalse() {
        user.setRole(null);
        assertFalse(user.isStaff());
    }
}
