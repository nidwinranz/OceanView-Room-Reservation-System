package model;

/**
 * Room – abstract base for the Factory Pattern.
 *
 * Factory Pattern: RoomFactory creates concrete Room objects (StandardRoom,
 * DeluxeRoom, SuiteRoom) without exposing instantiation logic to the caller.
 * This makes adding new room types easy without changing existing code (OCP).
 */
public abstract class Room {

    protected RoomType roomType;

    public RoomType getRoomType()         { return roomType; }
    public abstract double getPricePerNight();
    public abstract String getDescription();

    /** Calculate total cost for the given number of nights. */
    public double calculateCost(long nights) {
        return getPricePerNight() * nights;
    }
}
