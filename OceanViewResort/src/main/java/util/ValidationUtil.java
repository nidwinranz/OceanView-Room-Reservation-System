package util;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

/**
 * ValidationUtil – common input validation and sanitization helpers.
 */
public class ValidationUtil {

    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    /**
     * Returns true if the string is null or blank (empty / whitespace only).
     */
    public static boolean isEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }

    /**
     * Trims and returns the string. Returns empty string if null.
     */
    public static String sanitize(String value) {
        if (value == null) return "";
        return value.trim();
    }

    /**
     * Returns true if the string is a valid basic email format.
     */
    public static boolean isValidEmail(String email) {
        if (isEmpty(email)) return false;
        return email.matches("^[\\w._%+\\-]+@[\\w.\\-]+\\.[a-zA-Z]{2,}$");
    }

    /**
     * Returns true if the password meets minimum requirements (at least 6 chars).
     */
    public static boolean isValidPassword(String password) {
        return password != null && password.length() >= 6;
    }

    /**
     * Returns true if the reservation ID matches format: RES followed by digits.
     * Example valid: RES001, RES1234
     */
    public static boolean isValidReservationId(String reservationId) {
        if (isEmpty(reservationId)) return false;
        return reservationId.trim().matches("^RES\\d+$");
    }

    /**
     * Returns true if the phone number is a valid Sri Lankan mobile number.
     * Format: 07XXXXXXXX (10 digits starting with 07)
     */
    public static boolean isValidPhone(String phone) {
        if (isEmpty(phone)) return false;
        return phone.trim().matches("^07\\d{8}$");
    }

    /**
     * Returns true if the date string is a valid date in yyyy-MM-dd format.
     * Example valid: 2026-03-15
     */
    public static boolean isValidDate(String date) {
        if (isEmpty(date)) return false;
        try {
            LocalDate.parse(date.trim(), DATE_FORMAT);
            return true;
        } catch (DateTimeParseException e) {
            return false;
        }
    }

    /**
     * Returns true if checkOut date is strictly after checkIn date.
     * Both dates must be valid yyyy-MM-dd format strings.
     */
    public static boolean isCheckOutAfterCheckIn(String checkIn, String checkOut) {
        if (!isValidDate(checkIn) || !isValidDate(checkOut)) return false;
        LocalDate in  = LocalDate.parse(checkIn.trim(),  DATE_FORMAT);
        LocalDate out = LocalDate.parse(checkOut.trim(), DATE_FORMAT);
        return out.isAfter(in);
    }

    /**
     * Returns true if the guest name is non-empty and contains only letters/spaces.
     */
    public static boolean isValidGuestName(String name) {
        if (isEmpty(name)) return false;
        return name.trim().matches("^[a-zA-Z\\s.'-]{2,100}$");
    }
}
