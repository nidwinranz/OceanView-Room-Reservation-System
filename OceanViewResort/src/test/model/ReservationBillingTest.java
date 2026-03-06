package model;

import org.junit.Test;
import org.junit.Before;
import static org.junit.Assert.*;
import java.time.LocalDate;

/**
 * ReservationBillingTest – Unit tests for reservation billing calculations.
 *
 * Test Rationale:
 * Billing accuracy is critical for a hotel reservation system.
 * These tests verify that the total cost is correctly calculated
 * based on room type, number of nights, and guest details.
 * Any error in billing directly impacts the business financially.
 */
public class ReservationBillingTest {

    private Reservation reservation;

    @Before
    public void setUp() {
        reservation = new Reservation(
            "RES001", "Alice Fernando", "123 Main St",
            "0771234567", "alice@email.com", "NIC12345",
            2, 1, "None",
            "Standard", "S101",
            LocalDate.of(2026, 4, 1),
            LocalDate.of(2026, 4, 4),
            30000.0
        );
    }

    // ── Standard Room Billing Tests ───────────────────────────────────────────

    @Test
    public void testBilling_StandardRoom_1Night() {
        double cost = RoomFactory.calculateCost("Standard", 1);
        assertEquals(10000.0, cost, 0.001);
    }

    @Test
    public void testBilling_StandardRoom_3Nights() {
        double cost = RoomFactory.calculateCost("Standard", 3);
        assertEquals(30000.0, cost, 0.001);
    }

    @Test
    public void testBilling_StandardRoom_7Nights() {
        double cost = RoomFactory.calculateCost("Standard", 7);
        assertEquals(70000.0, cost, 0.001);
    }

    @Test
    public void testBilling_StandardRoom_30Nights() {
        double cost = RoomFactory.calculateCost("Standard", 30);
        assertEquals(300000.0, cost, 0.001);
    }

    // ── Deluxe Room Billing Tests ─────────────────────────────────────────────

    @Test
    public void testBilling_DeluxeRoom_1Night() {
        double cost = RoomFactory.calculateCost("Deluxe", 1);
        assertEquals(15000.0, cost, 0.001);
    }

    @Test
    public void testBilling_DeluxeRoom_3Nights() {
        double cost = RoomFactory.calculateCost("Deluxe", 3);
        assertEquals(45000.0, cost, 0.001);
    }

    @Test
    public void testBilling_DeluxeRoom_7Nights() {
        double cost = RoomFactory.calculateCost("Deluxe", 7);
        assertEquals(105000.0, cost, 0.001);
    }

    @Test
    public void testBilling_DeluxeRoom_30Nights() {
        double cost = RoomFactory.calculateCost("Deluxe", 30);
        assertEquals(450000.0, cost, 0.001);
    }

    // ── Suite Room Billing Tests ──────────────────────────────────────────────

    @Test
    public void testBilling_SuiteRoom_1Night() {
        double cost = RoomFactory.calculateCost("Suite", 1);
        assertEquals(25000.0, cost, 0.001);
    }

    @Test
    public void testBilling_SuiteRoom_3Nights() {
        double cost = RoomFactory.calculateCost("Suite", 3);
        assertEquals(75000.0, cost, 0.001);
    }

    @Test
    public void testBilling_SuiteRoom_7Nights() {
        double cost = RoomFactory.calculateCost("Suite", 7);
        assertEquals(175000.0, cost, 0.001);
    }

    @Test
    public void testBilling_SuiteRoom_30Nights() {
        double cost = RoomFactory.calculateCost("Suite", 30);
        assertEquals(750000.0, cost, 0.001);
    }

    // ── Zero and Edge Case Billing Tests ─────────────────────────────────────

    @Test
    public void testBilling_ZeroNights_ReturnsZero() {
        double cost = RoomFactory.calculateCost("Standard", 0);
        assertEquals(0.0, cost, 0.001);
    }

    @Test
    public void testBilling_ZeroNights_AllRoomTypes_ReturnZero() {
        assertEquals(0.0, RoomFactory.calculateCost("Standard", 0), 0.001);
        assertEquals(0.0, RoomFactory.calculateCost("Deluxe",   0), 0.001);
        assertEquals(0.0, RoomFactory.calculateCost("Suite",    0), 0.001);
    }

    @Test
    public void testBilling_InvalidRoomType_ThrowsException() {
        try {
            RoomFactory.calculateCost("InvalidRoom", 3);
            fail("Expected IllegalArgumentException");
        } catch (IllegalArgumentException e) {
            assertNotNull(e.getMessage());
        }
    }

    // ── Reservation Total Amount Tests ────────────────────────────────────────

    @Test
    public void testBilling_ReservationTotalAmount_MatchesExpected() {
        assertEquals(30000.0, reservation.getTotalAmount(), 0.001);
    }

    @Test
    public void testBilling_ReservationNights_MatchesCost() {
        long nights = reservation.getNights();
        double expectedCost = RoomFactory.calculateCost("Standard", nights);
        assertEquals(expectedCost, reservation.getTotalAmount(), 0.001);
    }

    @Test
    public void testBilling_UpdateTotalAmount() {
        reservation.setTotalAmount(45000.0);
        assertEquals(45000.0, reservation.getTotalAmount(), 0.001);
    }

    @Test
    public void testBilling_SuiteRoom_10Nights_HighValue() {
        double cost = RoomFactory.calculateCost("Suite", 10);
        assertEquals(250000.0, cost, 0.001);
        assertTrue("Suite 10-night cost should exceed 200,000", cost > 200000.0);
    }

    @Test
    public void testBilling_DeluxeCheaperThanSuite() {
        double deluxe = RoomFactory.calculateCost("Deluxe", 5);
        double suite  = RoomFactory.calculateCost("Suite",  5);
        assertTrue("Deluxe should always be cheaper than Suite", deluxe < suite);
    }

    @Test
    public void testBilling_StandardCheaperThanDeluxe() {
        double standard = RoomFactory.calculateCost("Standard", 5);
        double deluxe   = RoomFactory.calculateCost("Deluxe",   5);
        assertTrue("Standard should always be cheaper than Deluxe", standard < deluxe);
    }

    // ── Nightly Rate Verification Tests ──────────────────────────────────────

    @Test
    public void testBilling_StandardNightlyRate_IsCorrect() {
        StandardRoom room = new StandardRoom();
        assertEquals(10000.0, room.getPricePerNight(), 0.001);
    }

    @Test
    public void testBilling_DeluxeNightlyRate_IsCorrect() {
        DeluxeRoom room = new DeluxeRoom();
        assertEquals(15000.0, room.getPricePerNight(), 0.001);
    }

    @Test
    public void testBilling_SuiteNightlyRate_IsCorrect() {
        SuiteRoom room = new SuiteRoom();
        assertEquals(25000.0, room.getPricePerNight(), 0.001);
    }
}
