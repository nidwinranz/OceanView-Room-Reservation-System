package util;

import org.junit.Test;
import static org.junit.Assert.*;
import java.util.HashSet;
import java.util.Set;

/**
 * OTPGeneratorTest – Unit tests for OTPGenerator utility class.
 *
 * Test Rationale:
 * The OTP system is the security backbone of the password reset feature.
 * Tests verify that generated OTPs are always 6 digits, contain only numeric
 * characters, and that repeated calls produce sufficiently unique values.
 */
public class OTPGeneratorTest {

    @Test
    public void testGenerate_ReturnsNotNull() {
        String otp = OTPGenerator.generate();
        assertNotNull(otp);
    }

    @Test
    public void testGenerate_IsSixDigits() {
        String otp = OTPGenerator.generate();
        assertEquals(6, otp.length());
    }

    @Test
    public void testGenerate_ContainsOnlyDigits() {
        String otp = OTPGenerator.generate();
        assertTrue("OTP should contain only digits", otp.matches("\\d{6}"));
    }

    @Test
    public void testGenerate_MultipleCallsAllSixDigits() {
        for (int i = 0; i < 50; i++) {
            String otp = OTPGenerator.generate();
            assertEquals("OTP must always be 6 digits", 6, otp.length());
            assertTrue("OTP must be numeric", otp.matches("\\d{6}"));
        }
    }

    @Test
    public void testGenerate_ProducesUniqueValues() {
        // Generate 20 OTPs — at least some should be different
        Set<String> otps = new HashSet<>();
        for (int i = 0; i < 20; i++) {
            otps.add(OTPGenerator.generate());
        }
        // With 1,000,000 possible OTPs, 20 should not all be identical
        assertTrue("OTP generator should produce varied results", otps.size() > 1);
    }

    @Test
    public void testGenerate_StartsWithAnyDigit() {
        // Ensure leading zeros are handled (stored as String, not int)
        boolean foundLeadingZero = false;
        for (int i = 0; i < 200; i++) {
            String otp = OTPGenerator.generate();
            if (otp.startsWith("0")) {
                foundLeadingZero = true;
                assertEquals(6, otp.length()); // Must still be 6 chars
                break;
            }
        }
        // This test documents the behavior — OTPs are strings so leading zeros are valid
    }

    @Test
    public void testGenerate_ValueInRange() {
        for (int i = 0; i < 30; i++) {
            String otp = OTPGenerator.generate();
            int value = Integer.parseInt(otp);
            // 6-digit numeric string: 000000 to 999999
            assertTrue(value >= 0 && value <= 999999);
        }
    }
}
