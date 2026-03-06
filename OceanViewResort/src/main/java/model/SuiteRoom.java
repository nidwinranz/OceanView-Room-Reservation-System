package model;

/** Concrete room: Suite – LKR 25,000 / night */
public class SuiteRoom extends Room {

    public SuiteRoom() {
        this.roomType = RoomType.SUITE;
    }

    @Override public double getPricePerNight() { return RoomType.SUITE.getPricePerNight(); }

    @Override public String getDescription() {
        return "Luxury suite with panoramic ocean view, Jacuzzi, butler service, lounge area, and premium amenities.";
    }
}
