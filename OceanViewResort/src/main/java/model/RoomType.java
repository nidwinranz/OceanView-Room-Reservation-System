package model;

/**
 * RoomType – enumeration of available room categories with their nightly rates.
 *
 * Used by the Factory Pattern (RoomFactory) to create room-pricing objects.
 */
public enum RoomType {

    STANDARD("Standard", 10000.0),
    DELUXE  ("Deluxe",   15000.0),
    SUITE   ("Suite",    25000.0);

    private final String displayName;
    private final double pricePerNight;

    RoomType(String displayName, double pricePerNight) {
        this.displayName   = displayName;
        this.pricePerNight = pricePerNight;
    }

    public String getDisplayName()  { return displayName; }
    public double getPricePerNight(){ return pricePerNight; }

    /** Lookup by display name (case-insensitive). */
    public static RoomType fromString(String name) {
        for (RoomType rt : values()) {
            if (rt.displayName.equalsIgnoreCase(name)) return rt;
        }
        throw new IllegalArgumentException("Unknown room type: " + name);
    }
}
