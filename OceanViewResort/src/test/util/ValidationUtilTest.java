package util;

import org.junit.Test;
import static org.junit.Assert.*;

/**
 * ValidationUtilTest – Unit tests for ValidationUtil helper class.
 *
 * Test Rationale:
 * ValidationUtil is the gatekeeper for all user inputs across the application.
 * Thorough testing of each method ensures invalid data is caught before reaching
 * the database, preventing bad data and potential security issues.
 */
public class ValidationUtilTest {

    // ── isEmpty Tests ─────────────────────────────────────────────────────────

    @Test
    public void testIsEmpty_NullValue_ReturnsTrue() {
        assertTrue(ValidationUtil.isEmpty(null));
    }

    @Test
    public void testIsEmpty_EmptyString_ReturnsTrue() {
        assertTrue(ValidationUtil.isEmpty(""));
    }

    @Test
    public void testIsEmpty_WhitespaceOnly_ReturnsTrue() {
        assertTrue(ValidationUtil.isEmpty("   "));
    }

    @Test
    public void testIsEmpty_ValidString_ReturnsFalse() {
        assertFalse(ValidationUtil.isEmpty("hello"));
    }

    @Test
    public void testIsEmpty_StringWithSpaces_ReturnsFalse() {
        assertFalse(ValidationUtil.isEmpty("  hello  "));
    }

    // ── sanitize Tests ────────────────────────────────────────────────────────

    @Test
    public void testSanitize_TrimsWhitespace() {
        assertEquals("hello", ValidationUtil.sanitize("  hello  "));
    }

    @Test
    public void testSanitize_NullReturnsEmptyString() {
        assertEquals("", ValidationUtil.sanitize(null));
    }

    @Test
    public void testSanitize_NormalString_Unchanged() {
        assertEquals("OceanView", ValidationUtil.sanitize("OceanView"));
    }

    // ── isValidEmail Tests ────────────────────────────────────────────────────

    @Test
    public void testIsValidEmail_ValidEmail_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidEmail("user@example.com"));
    }

    @Test
    public void testIsValidEmail_ValidEmailWithDots_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidEmail("first.last@domain.org"));
    }

    @Test
    public void testIsValidEmail_ValidEmailWithPlus_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidEmail("user+tag@gmail.com"));
    }

    @Test
    public void testIsValidEmail_MissingAt_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidEmail("userdomain.com"));
    }

    @Test
    public void testIsValidEmail_MissingDomain_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidEmail("user@"));
    }

    @Test
    public void testIsValidEmail_MissingTLD_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidEmail("user@domain"));
    }

    @Test
    public void testIsValidEmail_NullEmail_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidEmail(null));
    }

    @Test
    public void testIsValidEmail_EmptyEmail_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidEmail(""));
    }

    // ── Email Character Validation Tests ──────────────────────────────────────

    @Test
    public void testIsValidEmail_WithSpaces_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidEmail("user name@example.com"));
    }

    @Test
    public void testIsValidEmail_WithSpecialChars_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidEmail("user#name@example.com"));
    }

    @Test
    public void testIsValidEmail_DoubleAt_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidEmail("user@@example.com"));
    }

    @Test
    public void testIsValidEmail_OnlyNumbers_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidEmail("1234567890"));
    }

    @Test
    public void testIsValidEmail_SqlInjection_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidEmail("' OR '1'='1"));
    }

    @Test
    public void testIsValidEmail_WithComma_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidEmail("user,name@example.com"));
    }

    @Test
    public void testIsValidEmail_WithBrackets_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidEmail("user<name>@example.com"));
    }

    // ── isValidPassword Tests ─────────────────────────────────────────────────

    @Test
    public void testIsValidPassword_SixChars_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidPassword("abc123"));
    }

    @Test
    public void testIsValidPassword_MoreThanSixChars_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidPassword("securepassword"));
    }

    @Test
    public void testIsValidPassword_FiveChars_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPassword("abc12"));
    }

    @Test
    public void testIsValidPassword_EmptyString_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPassword(""));
    }

    @Test
    public void testIsValidPassword_NullPassword_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPassword(null));
    }

    // ── Password Character Validation Tests ───────────────────────────────────

    @Test
    public void testIsValidPassword_WithSpecialChars_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidPassword("p@ssw0rd!"));
    }

    @Test
    public void testIsValidPassword_WithSpaces_ReturnsTrue() {
        // Password with spaces is allowed as long as length >= 6
        assertTrue(ValidationUtil.isValidPassword("my password"));
    }

    @Test
    public void testIsValidPassword_AllNumbers_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidPassword("123456"));
    }

    @Test
    public void testIsValidPassword_AllSpecialChars_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidPassword("@#$%^&"));
    }

    @Test
    public void testIsValidPassword_SingleChar_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPassword("a"));
    }

    @Test
    public void testIsValidPassword_WhitespaceOnly_ReturnsFalse() {
        // 5 spaces is under 6 chars when trimmed but we check raw length
        assertFalse(ValidationUtil.isValidPassword("  "));
    }

    @Test
    public void testIsValidPassword_SqlInjection_StillValidatesLength() {
        // SQL injection attempt — validation only checks length, not content
        assertTrue(ValidationUtil.isValidPassword("' OR 1=1--"));
    }

    // ── isValidReservationId Tests ────────────────────────────────────────────

    @Test
    public void testIsValidReservationId_ValidFormat_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidReservationId("RES001"));
    }

    @Test
    public void testIsValidReservationId_ValidLongFormat_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidReservationId("RES1234"));
    }

    @Test
    public void testIsValidReservationId_MissingRES_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidReservationId("001"));
    }

    @Test
    public void testIsValidReservationId_NoDigits_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidReservationId("RES"));
    }

    @Test
    public void testIsValidReservationId_Null_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidReservationId(null));
    }

    @Test
    public void testIsValidReservationId_Lowercase_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidReservationId("res001"));
    }

    // ── isValidPhone Tests ────────────────────────────────────────────────────

    @Test
    public void testIsValidPhone_ValidSriLankanNumber_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidPhone("0771234567"));
    }

    @Test
    public void testIsValidPhone_ValidStartingWith076_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidPhone("0761234567"));
    }

    @Test
    public void testIsValidPhone_NineDigits_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPhone("077123456"));
    }

    @Test
    public void testIsValidPhone_ElevenDigits_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPhone("07712345678"));
    }

    @Test
    public void testIsValidPhone_NotStartingWith07_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPhone("0812345678"));
    }

    @Test
    public void testIsValidPhone_Null_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPhone(null));
    }

    // ── Phone Character Validation Tests ─────────────────────────────────────

    @Test
    public void testIsValidPhone_WithLetters_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPhone("077ABCDEFG"));
    }

    @Test
    public void testIsValidPhone_WithSpaces_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPhone("077 123 456"));
    }

    @Test
    public void testIsValidPhone_WithDashes_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPhone("077-123-456"));
    }

    @Test
    public void testIsValidPhone_WithPlusSign_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPhone("+94771234567"));
    }

    @Test
    public void testIsValidPhone_WithSpecialChars_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPhone("077#234567"));
    }

    @Test
    public void testIsValidPhone_EmptyString_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPhone(""));
    }

    @Test
    public void testIsValidPhone_AllZeros_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidPhone("0000000000"));
    }

    // ── isValidDate Tests ─────────────────────────────────────────────────────

    @Test
    public void testIsValidDate_ValidDate_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidDate("2026-04-15"));
    }

    @Test
    public void testIsValidDate_InvalidFormat_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidDate("15-04-2026"));
    }

    @Test
    public void testIsValidDate_InvalidMonth_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidDate("2026-13-01"));
    }

    @Test
    public void testIsValidDate_NullDate_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidDate(null));
    }

    @Test
    public void testIsValidDate_EmptyString_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidDate(""));
    }

    // ── isCheckOutAfterCheckIn Tests ──────────────────────────────────────────

    @Test
    public void testIsCheckOutAfterCheckIn_Valid_ReturnsTrue() {
        assertTrue(ValidationUtil.isCheckOutAfterCheckIn("2026-04-01", "2026-04-05"));
    }

    @Test
    public void testIsCheckOutAfterCheckIn_SameDate_ReturnsFalse() {
        assertFalse(ValidationUtil.isCheckOutAfterCheckIn("2026-04-01", "2026-04-01"));
    }

    @Test
    public void testIsCheckOutAfterCheckIn_CheckOutBeforeCheckIn_ReturnsFalse() {
        assertFalse(ValidationUtil.isCheckOutAfterCheckIn("2026-04-05", "2026-04-01"));
    }

    @Test
    public void testIsCheckOutAfterCheckIn_InvalidDates_ReturnsFalse() {
        assertFalse(ValidationUtil.isCheckOutAfterCheckIn("bad-date", "2026-04-05"));
    }

    // ── isValidGuestName Tests ────────────────────────────────────────────────

    @Test
    public void testIsValidGuestName_ValidName_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidGuestName("Alice Fernando"));
    }

    @Test
    public void testIsValidGuestName_SingleName_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidGuestName("Alice"));
    }

    @Test
    public void testIsValidGuestName_WithHyphen_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidGuestName("Mary-Jane Watson"));
    }

    @Test
    public void testIsValidGuestName_WithNumbers_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidGuestName("Alice123"));
    }

    @Test
    public void testIsValidGuestName_Null_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidGuestName(null));
    }

    @Test
    public void testIsValidGuestName_SingleChar_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidGuestName("A"));
    }

    // ── Guest Name Character Validation Tests ─────────────────────────────────

    @Test
    public void testIsValidGuestName_WithAtSymbol_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidGuestName("Alice@Fernando"));
    }

    @Test
    public void testIsValidGuestName_WithHashSymbol_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidGuestName("Alice#Fernando"));
    }

    @Test
    public void testIsValidGuestName_WithExclamation_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidGuestName("Alice!"));
    }

    @Test
    public void testIsValidGuestName_WithDollarSign_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidGuestName("Alice$Fernando"));
    }

    @Test
    public void testIsValidGuestName_SqlInjection_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidGuestName("'; DROP TABLE users;--"));
    }

    @Test
    public void testIsValidGuestName_OnlySpaces_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidGuestName("     "));
    }

    @Test
    public void testIsValidGuestName_OnlyNumbers_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidGuestName("12345678"));
    }

    @Test
    public void testIsValidGuestName_WithApostrophe_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidGuestName("O'Brien"));
    }

    @Test
    public void testIsValidGuestName_ThreeWordName_ReturnsTrue() {
        assertTrue(ValidationUtil.isValidGuestName("Alice Mary Fernando"));
    }

    @Test
    public void testIsValidGuestName_WithSlash_ReturnsFalse() {
        assertFalse(ValidationUtil.isValidGuestName("Alice/Fernando"));
    }
}
