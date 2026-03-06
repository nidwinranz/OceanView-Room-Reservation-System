package model;

/**
 * RoomFactory – Factory Pattern
 * ------------------------------
 * Creates the correct Room sub-type based on a string room-type name.
 *
 * Why Factory Pattern?
 *  • Decouples object creation from business logic.
 *  • Adding a new room type only requires a new subclass + one case here.
 *  • Servlet/DAO code never uses `new StandardRoom()` directly.
 */
public class RoomFactory {

    /**
     * Returns a Room instance matching the given type name.
     *
     * @param roomTypeName "Standard" | "Deluxe" | "Suite"
     * @return Concrete Room object
     */
    public static Room createRoom(String roomTypeName) {
        RoomType type = RoomType.fromString(roomTypeName);
        switch (type) {
            case STANDARD: return new StandardRoom();
            case DELUXE:   return new DeluxeRoom();
            case SUITE:    return new SuiteRoom();
            default:       throw new IllegalArgumentException("Unsupported room type: " + roomTypeName);
        }
    }

    /**
     * Convenience: compute total bill without constructing a full Reservation.
     */
    public static double calculateCost(String roomTypeName, long nights) {
        return createRoom(roomTypeName).calculateCost(nights);
    }
}
