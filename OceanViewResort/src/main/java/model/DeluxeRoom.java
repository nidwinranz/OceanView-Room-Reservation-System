package model;

/** Concrete room: Deluxe – LKR 15,000 / night */
public class DeluxeRoom extends Room {

    public DeluxeRoom() {
        this.roomType = RoomType.DELUXE;
    }

    @Override public double getPricePerNight() { return RoomType.DELUXE.getPricePerNight(); }

    @Override public String getDescription() {
        return "Spacious deluxe room with ocean view, mini-bar, AC, Smart TV, and private balcony.";
    }
}
