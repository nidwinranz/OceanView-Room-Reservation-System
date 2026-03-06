package util;

import java.security.SecureRandom;

/**
 * OTPGenerator – generates secure 6-digit OTP codes.
 *
 * Uses SecureRandom (cryptographically strong) instead of
 * Random to prevent OTP prediction attacks.
 */
public class OTPGenerator {

    private static final SecureRandom random = new SecureRandom();
    private static final int OTP_LENGTH = 6;

    /**
     * Generates a random 6-digit numeric OTP.
     * Example output: "483921"
     */
    public static String generate() {
        StringBuilder otp = new StringBuilder();
        for (int i = 0; i < OTP_LENGTH; i++) {
            otp.append(random.nextInt(10)); // 0–9
        }
        return otp.toString();
    }
}
