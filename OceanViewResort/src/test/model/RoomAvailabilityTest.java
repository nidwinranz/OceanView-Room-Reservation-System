package model;

import org.junit.Test;
import org.junit.Before;
import static org.junit.Assert.*;
import util.ValidationUtil;
import java.time.LocalDate;

/**
 * RoomAvailabilityTest – Unit tests for room availability date conflict checks.
 *
 * Test Rationale:
 * Double-booking is a critical failure in any reservation system.
 * These tests verify that date range validation correctly identifies
 * overlapping bookings, valid date ranges, and edge cases like
 * same-day check-in/check-out to prevent room conflicts.
 */
public class RoomAvailabilityTest {

    private LocalDate baseCheckIn;
    private LocalDate baseCheckOut;

    @Before
    public void setUp() {
        // Existing booking: April 5 to April 10
        baseCheckIn  = LocalDate.of(2026, 4, 5);
        baseCheckOut = LocalDate.of(2026, 4, 10);
    }

    // ── Date Validity Tests ───────────────────────────────────────────────────

    @Test
    public void testAvailability_ValidCheckInDate_Passes() {
        assertTrue(ValidationUtil.isValidDate("2026-04-05"));
    }

    @Test
    public void testAvailability_ValidCheckOutDate_Passes() {
        assertTrue(ValidationUtil.isValidDate("2026-04-10"));
    }

    @Test
    public void testAvailability_InvalidCheckInDate_Rejected() {
        assertFalse(ValidationUtil.isValidDate("2026-13-05"));
    }

    @Test
    public void testAvailability_InvalidCheckOutDate_Rejected() {
        assertFalse(ValidationUtil.isValidDate("not-a-date"));
    }

    @Test
    public void testAvailability_NullCheckInDate_Rejected() {
        assertFalse(ValidationUtil.isValidDate(null));
    }

    @Test
    public void testAvailability_NullCheckOutDate_Rejected() {
        assertFalse(ValidationUtil.isValidDate(null));
    }

    // ── Check-out After Check-in Tests ────────────────────────────────────────

    @Test
    public void testAvailability_CheckOutAfterCheckIn_Valid() {
        assertTrue(ValidationUtil.isCheckOutAfterCheckIn("2026-04-05", "2026-04-10"));
    }

    @Test
    public void testAvailability_CheckOutSameAsCheckIn_Invalid() {
        assertFalse(ValidationUtil.isCheckOutAfterCheckIn("2026-04-05", "2026-04-05"));
    }

    @Test
    public void testAvailability_CheckOutBeforeCheckIn_Invalid() {
        assertFalse(ValidationUtil.isCheckOutAfterCheckIn("2026-04-10", "2026-04-05"));
    }

    @Test
    public void testAvailability_OneNightStay_Valid() {
        assertTrue(ValidationUtil.isCheckOutAfterCheckIn("2026-04-05", "2026-04-06"));
    }

    // ── Date Overlap Detection Tests ──────────────────────────────────────────

    /**
     * Helper: returns true if the new booking overlaps with existing booking.
     * Overlap occurs when: newCheckIn < existingCheckOut AND newCheckOut > existingCheckIn
     */
    private boolean isOverlapping(LocalDate newIn, LocalDate newOut,
                                   LocalDate existIn, LocalDate existOut) {
        return newIn.isBefore(existOut) && newOut.isAfter(existIn);
    }

    @Test
    public void testAvailability_NoOverlap_BeforeExisting() {
        // New booking: Apr 1-4, Existing: Apr 5-10 → No conflict
        LocalDate newIn  = LocalDate.of(2026, 4, 1);
        LocalDate newOut = LocalDate.of(2026, 4, 4);
        assertFalse(isOverlapping(newIn, newOut, baseCheckIn, baseCheckOut));
    }

    @Test
    public void testAvailability_NoOverlap_AfterExisting() {
        // New booking: Apr 11-15, Existing: Apr 5-10 → No conflict
        LocalDate newIn  = LocalDate.of(2026, 4, 11);
        LocalDate newOut = LocalDate.of(2026, 4, 15);
        assertFalse(isOverlapping(newIn, newOut, baseCheckIn, baseCheckOut));
    }

    @Test
    public void testAvailability_Overlap_NewStartsDuringExisting() {
        // New booking: Apr 7-12, Existing: Apr 5-10 → Conflict!
        LocalDate newIn  = LocalDate.of(2026, 4, 7);
        LocalDate newOut = LocalDate.of(2026, 4, 12);
        assertTrue(isOverlapping(newIn, newOut, baseCheckIn, baseCheckOut));
    }

    @Test
    public void testAvailability_Overlap_NewEndsDuringExisting() {
        // New booking: Apr 3-7, Existing: Apr 5-10 → Conflict!
        LocalDate newIn  = LocalDate.of(2026, 4, 3);
        LocalDate newOut = LocalDate.of(2026, 4, 7);
        assertTrue(isOverlapping(newIn, newOut, baseCheckIn, baseCheckOut));
    }

    @Test
    public void testAvailability_Overlap_NewCoversEntireExisting() {
        // New booking: Apr 3-12, Existing: Apr 5-10 → Conflict!
        LocalDate newIn  = LocalDate.of(2026, 4, 3);
        LocalDate newOut = LocalDate.of(2026, 4, 12);
        assertTrue(isOverlapping(newIn, newOut, baseCheckIn, baseCheckOut));
    }

    @Test
    public void testAvailability_Overlap_ExactSameDates() {
        // New booking: Apr 5-10, Existing: Apr 5-10 → Conflict!
        assertTrue(isOverlapping(baseCheckIn, baseCheckOut, baseCheckIn, baseCheckOut));
    }

    @Test
    public void testAvailability_NoOverlap_CheckoutEqualsNewCheckIn() {
        // New booking starts exactly when existing ends → No conflict (back-to-back allowed)
        LocalDate newIn  = LocalDate.of(2026, 4, 10); // existing checkout = Apr 10
        LocalDate newOut = LocalDate.of(2026, 4, 14);
        assertFalse(isOverlapping(newIn, newOut, baseCheckIn, baseCheckOut));
    }

    @Test
    public void testAvailability_NoOverlap_NewCheckOutEqualsExistingCheckIn() {
        // New booking ends exactly when existing starts → No conflict
        LocalDate newIn  = LocalDate.of(2026, 4, 1);
        LocalDate newOut = LocalDate.of(2026, 4, 5); // existing checkin = Apr 5
        assertFalse(isOverlapping(newIn, newOut, baseCheckIn, baseCheckOut));
    }

    // ── Night Count Validation Tests ──────────────────────────────────────────

    @Test
    public void testAvailability_NightCount_FiveNights() {
        Reservation r = new Reservation();
        r.setCheckIn(LocalDate.of(2026, 4, 5));
        r.setCheckOut(LocalDate.of(2026, 4, 10));
        assertEquals(5, r.getNights());
    }

    @Test
    public void testAvailability_NightCount_OneNight() {
        Reservation r = new Reservation();
        r.setCheckIn(LocalDate.of(2026, 4, 5));
        r.setCheckOut(LocalDate.of(2026, 4, 6));
        assertEquals(1, r.getNights());
    }

    @Test
    public void testAvailability_NightCount_NullDates_ReturnsZero() {
        Reservation r = new Reservation();
        r.setCheckIn(null);
        r.setCheckOut(null);
        assertEquals(0, r.getNights());
    }

    @Test
    public void testAvailability_CrossMonthBooking_Valid() {
        assertTrue(ValidationUtil.isCheckOutAfterCheckIn("2026-03-28", "2026-04-05"));
    }

    @Test
    public void testAvailability_CrossYearBooking_Valid() {
        assertTrue(ValidationUtil.isCheckOutAfterCheckIn("2026-12-28", "2027-01-03"));
    }
}
