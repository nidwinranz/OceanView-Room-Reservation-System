package service;

import dao.ReservationDAO;
import dao.ReservationDAOImpl;
import model.Reservation;
import model.RoomFactory;
import util.ValidationUtil;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;

public class ReservationService {

    private final ReservationDAO dao;

    public ReservationService() { this.dao = new ReservationDAOImpl(); }

    // ── Next Reservation ID ───────────────────────────────────────────────────
    // FIX: Old version used count()+1 which causes duplicate IDs when records
    // are deleted. Now tries RES0001, RES0002... until a unique one is found.
    public String getNextReservationId() {
        int attempt = dao.getAllReservations().size() + 1;
        String id;
        // Keep incrementing until we find an ID that doesn't exist
        do {
            id = String.format("RES%04d", attempt++);
        } while (dao.reservationIdExists(id));
        return id;
    }

    // ── Get available rooms for a type + date range ───────────────────────────
    public List<String> getAvailableRooms(String roomType, String checkIn, String checkOut) {
        return dao.getAvailableRooms(roomType, checkIn, checkOut);
    }

    // ── Auto-fill: get last reservation by national ID ────────────────────────
    public Reservation getGuestByNationalId(String nationalId) {
        return dao.getLastReservationByNationalId(nationalId);
    }

    // ── Add Reservation ───────────────────────────────────────────────────────
    public String addReservation(String reservationId, String guestName, String address,
                                  String contactNumber, String email, String nationalId,
                                  String numAdultsStr, String numChildrenStr,
                                  String specialRequests, String roomType, String roomNumber,
                                  String checkIn, String checkOut) {

        // Guest name: letters only
        if (ValidationUtil.isEmpty(guestName))
            return "Guest name is required.";
        if (!guestName.trim().matches("[A-Za-z\\s]+"))
            return "Guest name must contain letters only.";

        // Address
        if (ValidationUtil.isEmpty(address))
            return "Address is required.";

        // Phone: local or international
        if (ValidationUtil.isEmpty(contactNumber) ||
            !contactNumber.trim().matches("(\\+[1-9][0-9]{1,14}|0[0-9]{9})"))
            return "Invalid phone number. Use local (07XXXXXXXX) or international (+94XXXXXXXXX).";

        // Email (optional but validate if provided)
        if (!ValidationUtil.isEmpty(email) &&
            !email.trim().matches("^[\\w._%+\\-]+@[\\w.\\-]+\\.[a-zA-Z]{2,}$"))
            return "Invalid email address.";

        // National ID required
        if (ValidationUtil.isEmpty(nationalId))
            return "National ID / Passport number is required.";

        // Guest count
        int adults = 1, children = 0;
        try { adults   = Integer.parseInt(numAdultsStr);   }
        catch (Exception e) { return "Invalid number of adults."; }
        try { children = Integer.parseInt(numChildrenStr); }
        catch (Exception e) { return "Invalid number of children."; }
        if (adults < 1)   return "At least 1 adult is required.";
        if (children < 0) return "Number of children cannot be negative.";

        // Dates
        if (!ValidationUtil.isValidDate(checkIn))  return "Invalid check-in date.";
        if (!ValidationUtil.isValidDate(checkOut)) return "Invalid check-out date.";
        LocalDate in    = LocalDate.parse(checkIn);
        LocalDate out   = LocalDate.parse(checkOut);
        LocalDate today = LocalDate.now();
        if (in.isBefore(today))
            return "Check-in date cannot be in the past.";
        long nights = ChronoUnit.DAYS.between(in, out);
        if (nights < 1)
            return "Check-out must be at least 1 night after check-in.";

        // Room number required
        if (ValidationUtil.isEmpty(roomNumber))
            return "Please select a room number.";

        // Room conflict check
        if (!dao.isRoomAvailable(roomNumber, checkIn, checkOut, null)) {
            List<String> alternatives = dao.getAvailableRooms(roomType, checkIn, checkOut);
            if (alternatives.isEmpty())
                return "Room " + roomNumber + " is already booked for these dates. " +
                       "No other " + roomType + " rooms are available. Please change your dates.";
            return "Room " + roomNumber + " is already booked for these dates. " +
                   "Available " + roomType + " rooms: " + String.join(", ", alternatives);
        }

        // Calculate cost
        double total;
        try { total = RoomFactory.calculateCost(roomType, nights); }
        catch (IllegalArgumentException e) { return "Invalid room type selected."; }

        Reservation r = new Reservation(
            ValidationUtil.sanitize(reservationId),
            ValidationUtil.sanitize(guestName),
            ValidationUtil.sanitize(address),
            ValidationUtil.sanitize(contactNumber),
            ValidationUtil.sanitize(email),
            ValidationUtil.sanitize(nationalId),
            adults, children,
            specialRequests != null ? specialRequests.trim() : "",
            roomType,
            roomNumber,
            in, out, total
        );

        return dao.addReservation(r) ? null : "Database error: could not save reservation. Check Eclipse console.";
    }

    // ── Update Reservation ────────────────────────────────────────────────────
    public String updateReservation(String reservationId, String guestName, String address,
                                     String contactNumber, String email, String nationalId,
                                     String numAdultsStr, String numChildrenStr,
                                     String specialRequests, String roomType, String roomNumber,
                                     String checkIn, String checkOut) {

        if (ValidationUtil.isEmpty(guestName))         return "Guest name is required.";
        if (!guestName.trim().matches("[A-Za-z\\s]+")) return "Guest name must contain letters only.";
        if (ValidationUtil.isEmpty(address))           return "Address is required.";
        if (ValidationUtil.isEmpty(contactNumber) ||
            !contactNumber.trim().matches("(\\+[1-9][0-9]{1,14}|0[0-9]{9})"))
            return "Invalid phone number.";
        if (!ValidationUtil.isEmpty(email) &&
            !email.trim().matches("^[\\w._%+\\-]+@[\\w.\\-]+\\.[a-zA-Z]{2,}$"))
            return "Invalid email address.";
        if (ValidationUtil.isEmpty(nationalId)) return "National ID / Passport number is required.";

        int adults = 1, children = 0;
        try { adults   = Integer.parseInt(numAdultsStr);   } catch (Exception e) { return "Invalid number of adults."; }
        try { children = Integer.parseInt(numChildrenStr); } catch (Exception e) { return "Invalid number of children."; }
        if (adults < 1)   return "At least 1 adult is required.";
        if (children < 0) return "Number of children cannot be negative.";

        if (!ValidationUtil.isValidDate(checkIn))  return "Invalid check-in date.";
        if (!ValidationUtil.isValidDate(checkOut)) return "Invalid check-out date.";
        LocalDate in  = LocalDate.parse(checkIn);
        LocalDate out = LocalDate.parse(checkOut);
        long nights   = ChronoUnit.DAYS.between(in, out);
        if (nights < 1) return "Check-out must be at least 1 night after check-in.";

        if (ValidationUtil.isEmpty(roomNumber)) return "Please select a room number.";

        // Room conflict check (exclude the current reservation being edited)
        if (!dao.isRoomAvailable(roomNumber, checkIn, checkOut, reservationId)) {
            List<String> alternatives = dao.getAvailableRooms(roomType, checkIn, checkOut);
            if (alternatives.isEmpty())
                return "Room " + roomNumber + " is already booked for these dates. No other " + roomType + " rooms available.";
            return "Room " + roomNumber + " is already booked. Available " + roomType + " rooms: " + String.join(", ", alternatives);
        }

        double total;
        try { total = RoomFactory.calculateCost(roomType, nights); }
        catch (IllegalArgumentException e) { return "Invalid room type selected."; }

        Reservation r = new Reservation(
            reservationId,
            ValidationUtil.sanitize(guestName),
            ValidationUtil.sanitize(address),
            ValidationUtil.sanitize(contactNumber),
            ValidationUtil.sanitize(email),
            ValidationUtil.sanitize(nationalId),
            adults, children,
            specialRequests != null ? specialRequests.trim() : "",
            roomType, roomNumber, in, out, total
        );
        return dao.updateReservation(r) ? null : "Database error: could not update reservation.";
    }

    // ── Delete ────────────────────────────────────────────────────────────────
    public boolean deleteReservation(String id) { return dao.deleteReservation(id); }

    // ── Lookups ───────────────────────────────────────────────────────────────
    public Reservation       getReservationById(String id)  { return dao.getReservationById(id); }
    public List<Reservation> getAllReservations()            { return dao.getAllReservations(); }
    public double            getTotalIncome()                { return dao.getTotalIncome(); }
    public Map<String,Long>  getCountByRoomType()            { return dao.getCountByRoomType(); }
    public List<Reservation> getActiveReservations()         { return dao.getActiveReservations(); }
}
