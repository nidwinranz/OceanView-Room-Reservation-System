package model;

/** Concrete room: Standard – LKR 10,000 / night */
public class StandardRoom extends Room {

    public StandardRoom() {
        this.roomType = RoomType.STANDARD;
    }

    @Override public double getPricePerNight() { return RoomType.STANDARD.getPricePerNight(); }

    @Override public String getDescription() {
        return "Comfortable standard room with garden view, AC, TV, and en-suite bathroom.";
    }
}
