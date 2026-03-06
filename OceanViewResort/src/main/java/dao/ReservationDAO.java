package dao;

import model.Reservation;
import java.util.List;
import java.util.Map;

public interface ReservationDAO {
    boolean           addReservation(Reservation r);
    Reservation       getReservationById(String id);
    List<Reservation> getAllReservations();
    boolean           updateReservation(Reservation r);
    boolean           deleteReservation(String id);

    // Room conflict checking
    List<String>      getAvailableRooms(String roomType, String checkIn, String checkOut);
    boolean           isRoomAvailable(String roomNumber, String checkIn, String checkOut, String excludeResId);

    // Returning guest auto-fill
    Reservation       getLastReservationByNationalId(String nationalId);

    // Reports
    double            getTotalIncome();
    Map<String,Long>  getCountByRoomType();
    List<Reservation> getActiveReservations();
    boolean           reservationIdExists(String id);
}
