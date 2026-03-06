package model;

import org.junit.Test;
import org.junit.Before;
import static org.junit.Assert.*;
import java.time.LocalDate;

/**
 * ReservationTest – Unit tests for the Reservation model.
 *
 * Test Rationale:
 * Reservation is the central business object. Tests verify that night calculation
 * (getNights) and guest total (getTotalGuests) are computed accurately, as billing
 * depends directly on these values.
 */
public class ReservationTest {

    private Reservation reservation;

    @Before
    public void setUp() {
        reservation = new Reservation(
            "RES001", "Alice Fernando", "123 Main St",
            "0771234567", "alice@email.com", "NIC12345",
            2, 1, "Sea view preferred",
            "Deluxe", "D101",
            LocalDate.of(2026, 4, 1),
            LocalDate.of(2026, 4, 5),
            60000.0
        );
    }

    // ── Constructor Tests ─────────────────────────────────────────────────────

    @Test
    public void testParameterizedConstructor_AllFieldsSet() {
        assertEquals("RES001", reservation.getReservationId());
        assertEquals("Alice Fernando", reservation.getGuestName());
        assertEquals("123 Main St", reservation.getAddress());
        assertEquals("0771234567", reservation.getContactNumber());
        assertEquals("alice@email.com", reservation.getEmail());
        assertEquals("NIC12345", reservation.getNationalId());
        assertEquals(2, reservation.getNumAdults());
        assertEquals(1, reservation.getNumChildren());
        assertEquals("Deluxe", reservation.getRoomType());
        assertEquals("D101", reservation.getRoomNumber());
        assertEquals(60000.0, reservation.getTotalAmount(), 0.001);
    }

    @Test
    public void testDefaultConstructor() {
        Reservation r = new Reservation();
        assertNull(r.getReservationId());
        assertEquals(0, r.getNumAdults());
    }

    // ── getNights Tests ───────────────────────────────────────────────────────

    @Test
    public void testGetNights_FourNights() {
        assertEquals(4, reservation.getNights());
    }

    @Test
    public void testGetNights_OneNight() {
        reservation.setCheckIn(LocalDate.of(2026, 5, 1));
        reservation.setCheckOut(LocalDate.of(2026, 5, 2));
        assertEquals(1, reservation.getNights());
    }

    @Test
    public void testGetNights_TenNights() {
        reservation.setCheckIn(LocalDate.of(2026, 6, 1));
        reservation.setCheckOut(LocalDate.of(2026, 6, 11));
        assertEquals(10, reservation.getNights());
    }

    @Test
    public void testGetNights_WhenCheckInIsNull_ReturnsZero() {
        reservation.setCheckIn(null);
        assertEquals(0, reservation.getNights());
    }

    @Test
    public void testGetNights_WhenCheckOutIsNull_ReturnsZero() {
        reservation.setCheckOut(null);
        assertEquals(0, reservation.getNights());
    }

    // ── getTotalGuests Tests ──────────────────────────────────────────────────

    @Test
    public void testGetTotalGuests_AdultsAndChildren() {
        assertEquals(3, reservation.getTotalGuests());
    }

    @Test
    public void testGetTotalGuests_OnlyAdults() {
        reservation.setNumChildren(0);
        assertEquals(2, reservation.getTotalGuests());
    }

    @Test
    public void testGetTotalGuests_SingleAdult() {
        reservation.setNumAdults(1);
        reservation.setNumChildren(0);
        assertEquals(1, reservation.getTotalGuests());
    }

    // ── Setter Tests ──────────────────────────────────────────────────────────

    @Test
    public void testSetTotalAmount() {
        reservation.setTotalAmount(90000.0);
        assertEquals(90000.0, reservation.getTotalAmount(), 0.001);
    }

    @Test
    public void testSetVip() {
        reservation.setVip(true);
        assertTrue(reservation.isVip());
    }

    @Test
    public void testSetRoomType() {
        reservation.setRoomType("Suite");
        assertEquals("Suite", reservation.getRoomType());
    }

    @Test
    public void testSetSpecialRequests() {
        reservation.setSpecialRequests("Extra pillows");
        assertEquals("Extra pillows", reservation.getSpecialRequests());
    }

    // ── Cross-month Date Tests ────────────────────────────────────────────────

    @Test
    public void testGetNights_CrossMonth() {
        reservation.setCheckIn(LocalDate.of(2026, 3, 28));
        reservation.setCheckOut(LocalDate.of(2026, 4, 2));
        assertEquals(5, reservation.getNights());
    }

    @Test
    public void testGetNights_CrossYear() {
        reservation.setCheckIn(LocalDate.of(2026, 12, 30));
        reservation.setCheckOut(LocalDate.of(2027, 1, 3));
        assertEquals(4, reservation.getNights());
    }
}
