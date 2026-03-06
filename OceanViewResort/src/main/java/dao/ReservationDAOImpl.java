package dao;

import model.Reservation;
import util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class ReservationDAOImpl implements ReservationDAO {

    // ── Room numbers by type ──────────────────────────────────────────────────
    // Standard: 7 rooms (101–107)
    // Deluxe:   4 rooms (201–204)
    // Suite:    3 rooms (301–303)
    private static final Map<String, List<String>> ROOMS = new LinkedHashMap<>();
    static {
        ROOMS.put("Standard", Arrays.asList("101","102","103","104","105","106","107"));
        ROOMS.put("Deluxe",   Arrays.asList("201","202","203","204"));
        ROOMS.put("Suite",    Arrays.asList("301","302","303"));
    }

    // ── Helper: map ResultSet → Reservation ──────────────────────────────────
    private Reservation mapRow(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setReservationId(rs.getString("reservation_id"));
        r.setGuestName(rs.getString("guest_name"));
        r.setAddress(rs.getString("address"));
        r.setContactNumber(rs.getString("contact_number"));
        r.setEmail(rs.getString("email"));
        r.setNationalId(rs.getString("national_id"));
        r.setNumAdults(rs.getInt("num_adults"));
        r.setNumChildren(rs.getInt("num_children"));
        r.setSpecialRequests(rs.getString("special_requests"));
        r.setVip(rs.getBoolean("is_vip"));
        r.setRoomType(rs.getString("room_type"));
        r.setRoomNumber(rs.getString("room_number"));
        r.setCheckIn(rs.getDate("check_in").toLocalDate());
        r.setCheckOut(rs.getDate("check_out").toLocalDate());
        r.setTotalAmount(rs.getDouble("total_amount"));
        return r;
    }

    // ── Add Reservation ───────────────────────────────────────────────────────
    @Override
    public boolean addReservation(Reservation r) {
        // Auto-mark as VIP if guest has stayed before
        boolean vip = getLastReservationByNationalId(r.getNationalId()) != null;
        r.setVip(vip);

        String sql = "INSERT INTO reservations " +
                     "(guest_name, address, contact_number, email, national_id, " +
                     "num_adults, num_children, special_requests, is_vip, " +
                     "room_type, room_number, check_in, check_out, total_amount) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1,  r.getGuestName());
            ps.setString(2,  r.getAddress());
            ps.setString(3,  r.getContactNumber());
            ps.setString(4,  r.getEmail());
            ps.setString(5,  r.getNationalId());
            ps.setInt(6,     r.getNumAdults());
            ps.setInt(7,     r.getNumChildren());
            ps.setString(8,  r.getSpecialRequests());
            ps.setBoolean(9, r.isVip());
            ps.setString(10, r.getRoomType());
            ps.setString(11, r.getRoomNumber());
            ps.setDate(12,   r.getCheckIn()  != null ? Date.valueOf(r.getCheckIn())  : null);
            ps.setDate(13,   r.getCheckOut() != null ? Date.valueOf(r.getCheckOut()) : null);
            ps.setDouble(14, r.getTotalAmount());
            boolean ok = ps.executeUpdate() > 0;
            System.out.println("[ReservationDAO] addReservation result: " + ok + " | room=" + r.getRoomNumber());
            return ok;
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] addReservation ERROR: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ── Update Reservation ────────────────────────────────────────────────────
    @Override
    public boolean updateReservation(Reservation r) {
        String sql = "UPDATE reservations SET guest_name=?, address=?, contact_number=?, " +
                     "email=?, national_id=?, num_adults=?, num_children=?, special_requests=?, " +
                     "room_type=?, room_number=?, check_in=?, check_out=?, total_amount=? " +
                     "WHERE reservation_id=?";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1,  r.getGuestName());
            ps.setString(2,  r.getAddress());
            ps.setString(3,  r.getContactNumber());
            ps.setString(4,  r.getEmail());
            ps.setString(5,  r.getNationalId());
            ps.setInt(6,     r.getNumAdults());
            ps.setInt(7,     r.getNumChildren());
            ps.setString(8,  r.getSpecialRequests());
            ps.setString(9,  r.getRoomType());
            ps.setString(10, r.getRoomNumber());
            ps.setDate(11,   r.getCheckIn()  != null ? Date.valueOf(r.getCheckIn())  : null);
            ps.setDate(12,   r.getCheckOut() != null ? Date.valueOf(r.getCheckOut()) : null);
            ps.setDouble(13, r.getTotalAmount());
            ps.setString(14, r.getReservationId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] updateReservation ERROR: " + e.getMessage());
            return false;
        }
    }

    // ── Delete ────────────────────────────────────────────────────────────────
    @Override
    public boolean deleteReservation(String id) {
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement("DELETE FROM reservations WHERE reservation_id=?");
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] deleteReservation ERROR: " + e.getMessage());
            return false;
        }
    }

    // ── Get Available Rooms ───────────────────────────────────────────────────
    // FIX: Previous version silently swallowed errors.
    // FIX: Properly filters only rooms with OVERLAPPING bookings.
    // A booking overlaps if: existingCheckIn < newCheckOut AND existingCheckOut > newCheckIn
    @Override
    public List<String> getAvailableRooms(String roomType, String checkIn, String checkOut) {
        List<String> allRooms = ROOMS.getOrDefault(roomType, new ArrayList<>());

        // If dates not provided, return all rooms as available
        if (checkIn == null || checkOut == null || checkIn.isEmpty() || checkOut.isEmpty()) {
            System.out.println("[ReservationDAO] No dates provided, returning all " + roomType + " rooms: " + allRooms);
            return new ArrayList<>(allRooms);
        }

        // Query: find room numbers that are BOOKED during the requested period
        // Overlap condition: existing check_in < new check_out AND existing check_out > new check_in
        String sql = "SELECT DISTINCT room_number FROM reservations " +
                     "WHERE room_type = ? " +
                     "AND room_number IS NOT NULL " +
                     "AND room_number != '' " +
                     "AND check_in  < ? " +   // existing booking starts before new checkout
                     "AND check_out > ?";      // existing booking ends after new checkin

        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, roomType);
            ps.setDate(2, Date.valueOf(checkOut));   // existing.checkIn < newCheckOut
            ps.setDate(3, Date.valueOf(checkIn));    // existing.checkOut > newCheckIn

            ResultSet rs = ps.executeQuery();
            Set<String> bookedRooms = new HashSet<>();
            while (rs.next()) {
                String booked = rs.getString("room_number");
                if (booked != null && !booked.trim().isEmpty()) {
                    bookedRooms.add(booked.trim());
                }
            }

            System.out.println("[ReservationDAO] " + roomType + " booked rooms for " +
                               checkIn + " to " + checkOut + ": " + bookedRooms);

            // Return only rooms NOT in the booked set
            List<String> available = new ArrayList<>();
            for (String room : allRooms) {
                if (!bookedRooms.contains(room)) {
                    available.add(room);
                }
            }

            System.out.println("[ReservationDAO] Available " + roomType + " rooms: " + available);
            return available;

        } catch (Exception e) {
            // Log the REAL error — don't silently swallow it
            System.err.println("[ReservationDAO] getAvailableRooms ERROR: " + e.getMessage());
            e.printStackTrace();
            // Return ALL rooms on error so booking is not completely blocked
            return new ArrayList<>(allRooms);
        }
    }

    // ── Check if one specific room is available ───────────────────────────────
    @Override
    public boolean isRoomAvailable(String roomNumber, String checkIn, String checkOut, String excludeResId) {
        String sql = "SELECT COUNT(*) FROM reservations " +
                     "WHERE room_number = ? " +
                     "AND room_number IS NOT NULL " +
                     "AND room_number != '' " +
                     "AND check_in  < ? " +
                     "AND check_out > ? " +
                     "AND reservation_id != ?";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, roomNumber);
            ps.setDate(2, Date.valueOf(checkOut));
            ps.setDate(3, Date.valueOf(checkIn));
            ps.setString(4, excludeResId != null ? excludeResId : "");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt(1);
                System.out.println("[ReservationDAO] isRoomAvailable(" + roomNumber + "): conflict count=" + count);
                return count == 0; // available if no conflicts
            }
        } catch (Exception e) {
            System.err.println("[ReservationDAO] isRoomAvailable ERROR: " + e.getMessage());
            e.printStackTrace();
            return true; // assume available on error
        }
        return false;
    }

    // ── Get last reservation by National ID (returning guest) ─────────────────
    @Override
    public Reservation getLastReservationByNationalId(String nationalId) {
        if (nationalId == null || nationalId.trim().isEmpty()) return null;
        String sql = "SELECT * FROM reservations WHERE national_id=? ORDER BY created_at DESC LIMIT 1";
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, nationalId.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] getLastByNationalId ERROR: " + e.getMessage());
        }
        return null;
    }

    // ── Get by ID ─────────────────────────────────────────────────────────────
    @Override
    public Reservation getReservationById(String id) {
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM reservations WHERE reservation_id=?");
            ps.setString(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] getById ERROR: " + e.getMessage());
        }
        return null;
    }

    // ── Get All ───────────────────────────────────────────────────────────────
    @Override
    public List<Reservation> getAllReservations() {
        List<Reservation> list = new ArrayList<>();
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            ResultSet rs = conn.createStatement().executeQuery(
                "SELECT * FROM reservations ORDER BY created_at DESC");
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] getAll ERROR: " + e.getMessage());
        }
        return list;
    }

    // ── Reservation ID Exists ─────────────────────────────────────────────────
    @Override
    public boolean reservationIdExists(String id) {
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM reservations WHERE reservation_id=?");
            ps.setString(1, id);
            return ps.executeQuery().next();
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] idExists ERROR: " + e.getMessage());
        }
        return false;
    }

    // ── Reports ───────────────────────────────────────────────────────────────
    @Override
    public double getTotalIncome() {
        try {
            ResultSet rs = DBConnection.getInstance().getConnection()
                .createStatement().executeQuery("SELECT COALESCE(SUM(total_amount),0) FROM reservations");
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] getTotalIncome ERROR: " + e.getMessage());
        }
        return 0;
    }

    @Override
    public Map<String, Long> getCountByRoomType() {
        Map<String, Long> map = new LinkedHashMap<>();
        try {
            ResultSet rs = DBConnection.getInstance().getConnection()
                .createStatement().executeQuery(
                    "SELECT room_type, COUNT(*) AS cnt FROM reservations GROUP BY room_type ORDER BY room_type");
            while (rs.next()) map.put(rs.getString("room_type"), rs.getLong("cnt"));
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] getCountByRoomType ERROR: " + e.getMessage());
        }
        return map;
    }

    @Override
    public List<Reservation> getActiveReservations() {
        List<Reservation> list = new ArrayList<>();
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "SELECT * FROM reservations WHERE check_out >= ? ORDER BY check_in");
            ps.setDate(1, Date.valueOf(LocalDate.now()));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[ReservationDAO] getActive ERROR: " + e.getMessage());
        }
        return list;
    }
}
