package model;

import org.junit.Test;
import org.junit.Before;
import static org.junit.Assert.*;
/**
 * RoomTest – Unit tests for Room subclasses and RoomFactory.
 *
 * Test Rationale:
 * The Room hierarchy uses the Factory Pattern for object creation. Tests verify
 * that each room type returns correct prices, descriptions, and cost calculations.
 * RoomFactory tests ensure correct objects are created and invalid inputs are rejected.
 */
public class RoomTest {

    // ── StandardRoom Tests ────────────────────────────────────────────────────

    @Test
    public void testStandardRoom_PricePerNight() {
        StandardRoom room = new StandardRoom();
        assertEquals(10000.0, room.getPricePerNight(), 0.001);
    }

    @Test
    public void testStandardRoom_RoomType() {
        StandardRoom room = new StandardRoom();
        assertEquals(RoomType.STANDARD, room.getRoomType());
    }

    @Test
    public void testStandardRoom_DescriptionNotEmpty() {
        StandardRoom room = new StandardRoom();
        assertNotNull(room.getDescription());
        assertFalse(room.getDescription().isEmpty());
    }

    @Test
    public void testStandardRoom_CalculateCost_3Nights() {
        StandardRoom room = new StandardRoom();
        assertEquals(30000.0, room.calculateCost(3), 0.001);
    }

    // ── DeluxeRoom Tests ──────────────────────────────────────────────────────

    @Test
    public void testDeluxeRoom_PricePerNight() {
        DeluxeRoom room = new DeluxeRoom();
        assertEquals(15000.0, room.getPricePerNight(), 0.001);
    }

    @Test
    public void testDeluxeRoom_RoomType() {
        DeluxeRoom room = new DeluxeRoom();
        assertEquals(RoomType.DELUXE, room.getRoomType());
    }

    @Test
    public void testDeluxeRoom_DescriptionNotEmpty() {
        DeluxeRoom room = new DeluxeRoom();
        assertNotNull(room.getDescription());
        assertFalse(room.getDescription().isEmpty());
    }

    @Test
    public void testDeluxeRoom_CalculateCost_5Nights() {
        DeluxeRoom room = new DeluxeRoom();
        assertEquals(75000.0, room.calculateCost(5), 0.001);
    }

    // ── SuiteRoom Tests ───────────────────────────────────────────────────────

    @Test
    public void testSuiteRoom_PricePerNight() {
        SuiteRoom room = new SuiteRoom();
        assertEquals(25000.0, room.getPricePerNight(), 0.001);
    }

    @Test
    public void testSuiteRoom_RoomType() {
        SuiteRoom room = new SuiteRoom();
        assertEquals(RoomType.SUITE, room.getRoomType());
    }

    @Test
    public void testSuiteRoom_DescriptionNotEmpty() {
        SuiteRoom room = new SuiteRoom();
        assertNotNull(room.getDescription());
        assertFalse(room.getDescription().isEmpty());
    }

    @Test
    public void testSuiteRoom_CalculateCost_7Nights() {
        SuiteRoom room = new SuiteRoom();
        assertEquals(175000.0, room.calculateCost(7), 0.001);
    }

    // ── calculateCost Edge Cases ──────────────────────────────────────────────

    @Test
    public void testCalculateCost_ZeroNights_ReturnsZero() {
        StandardRoom room = new StandardRoom();
        assertEquals(0.0, room.calculateCost(0), 0.001);
    }

    @Test
    public void testCalculateCost_OneNight() {
        DeluxeRoom room = new DeluxeRoom();
        assertEquals(15000.0, room.calculateCost(1), 0.001);
    }

    // ── RoomFactory Tests ─────────────────────────────────────────────────────

    @Test
    public void testRoomFactory_CreatesStandardRoom() {
        Room room = RoomFactory.createRoom("Standard");
        assertNotNull(room);
        assertTrue(room instanceof StandardRoom);
    }

    @Test
    public void testRoomFactory_CreatesDeluxeRoom() {
        Room room = RoomFactory.createRoom("Deluxe");
        assertNotNull(room);
        assertTrue(room instanceof DeluxeRoom);
    }

    @Test
    public void testRoomFactory_CreatesSuiteRoom() {
        Room room = RoomFactory.createRoom("Suite");
        assertNotNull(room);
        assertTrue(room instanceof SuiteRoom);
    }

    @Test
    public void testRoomFactory_CaseInsensitive() {
        Room room = RoomFactory.createRoom("standard");
        assertNotNull(room);
        assertTrue(room instanceof StandardRoom);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRoomFactory_InvalidType_ThrowsException() {
        RoomFactory.createRoom("PenthouseSuite");
    }

    @Test
    public void testRoomFactory_CalculateCost_Standard_2Nights() {
        double cost = RoomFactory.calculateCost("Standard", 2);
        assertEquals(20000.0, cost, 0.001);
    }

    @Test
    public void testRoomFactory_CalculateCost_Suite_10Nights() {
        double cost = RoomFactory.calculateCost("Suite", 10);
        assertEquals(250000.0, cost, 0.001);
    }

    // ── RoomType Enum Tests ───────────────────────────────────────────────────

    @Test
    public void testRoomType_FromString_Standard() {
        RoomType rt = RoomType.fromString("Standard");
        assertEquals(RoomType.STANDARD, rt);
    }

    @Test
    public void testRoomType_FromString_CaseInsensitive() {
        RoomType rt = RoomType.fromString("DELUXE");
        assertEquals(RoomType.DELUXE, rt);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRoomType_FromString_InvalidName_ThrowsException() {
        RoomType.fromString("Unknown");
    }

    @Test
    public void testRoomType_Prices() {
        assertEquals(10000.0, RoomType.STANDARD.getPricePerNight(), 0.001);
        assertEquals(15000.0, RoomType.DELUXE.getPricePerNight(), 0.001);
        assertEquals(25000.0, RoomType.SUITE.getPricePerNight(), 0.001);
    }
}
