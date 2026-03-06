package api;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Reservation;
import service.ReservationService;
import util.ValidationUtil;
import java.io.*;
import java.util.List;

/**
 * ReservationApiServlet – REST Web Service
 * Endpoints:
 *   GET  /api/reservations         → return all reservations as JSON
 *   GET  /api/reservation?id=xxx   → return one reservation as JSON
 *   POST /api/reservation          → add reservation, return JSON result
 */
@WebServlet(name = "ReservationApiServlet", urlPatterns = {"/api/reservations", "/api/reservation"})
public class ReservationApiServlet extends HttpServlet {

    private final ReservationService svc = new ReservationService();

    // ── GET ───────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        String path = req.getServletPath();

        if ("/api/reservations".equals(path)) {
            out.print(reservationListToJson(svc.getAllReservations()));
        } else {
            String id = ValidationUtil.sanitize(req.getParameter("id"));
            if (ValidationUtil.isEmpty(id)) {
                resp.setStatus(400);
                out.print("{\"error\":\"id parameter is required\"}");
                return;
            }
            Reservation r = svc.getReservationById(id);
            if (r == null) {
                resp.setStatus(404);
                out.print("{\"error\":\"Reservation not found: " + escJson(id) + "\"}");
            } else {
                out.print(reservationToJson(r));
            }
        }
    }

    // ── POST ──────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        // Read all parameters (old + new fields)
        String reservationId  = req.getParameter("reservationId");
        String guestName      = req.getParameter("guestName");
        String address        = req.getParameter("address");
        String contactNumber  = req.getParameter("contactNumber");
        String email          = req.getParameter("email");
        String nationalId     = req.getParameter("nationalId");
        String numAdults      = req.getParameter("numAdults")   != null ? req.getParameter("numAdults")   : "1";
        String numChildren    = req.getParameter("numChildren") != null ? req.getParameter("numChildren") : "0";
        String specialReqs    = req.getParameter("specialRequests");
        String roomType       = req.getParameter("roomType");
        String roomNumber     = req.getParameter("roomNumber");
        String checkIn        = req.getParameter("checkIn");
        String checkOut       = req.getParameter("checkOut");

        String error = svc.addReservation(
            reservationId, guestName, address, contactNumber,
            email, nationalId, numAdults, numChildren, specialReqs,
            roomType, roomNumber, checkIn, checkOut
        );

        if (error == null) {
            resp.setStatus(201);
            out.print("{\"success\":true,\"message\":\"Reservation created successfully.\",\"reservationId\":\"" + escJson(reservationId) + "\"}");
        } else {
            resp.setStatus(400);
            out.print("{\"success\":false,\"error\":\"" + escJson(error) + "\"}");
        }
    }

    // ── JSON helpers ──────────────────────────────────────────────────────────
    private String reservationToJson(Reservation r) {
        return "{"
            + "\"reservationId\":\""   + escJson(r.getReservationId())                          + "\","
            + "\"guestName\":\""       + escJson(r.getGuestName())                              + "\","
            + "\"address\":\""         + escJson(r.getAddress())                                + "\","
            + "\"contactNumber\":\""   + escJson(r.getContactNumber())                          + "\","
            + "\"email\":\""           + escJson(r.getEmail() != null ? r.getEmail() : "")      + "\","
            + "\"nationalId\":\""      + escJson(r.getNationalId() != null ? r.getNationalId() : "") + "\","
            + "\"numAdults\":"         + r.getNumAdults()                                        + ","
            + "\"numChildren\":"       + r.getNumChildren()                                      + ","
            + "\"specialRequests\":\"" + escJson(r.getSpecialRequests() != null ? r.getSpecialRequests() : "") + "\","
            + "\"isVip\":"             + r.isVip()                                               + ","
            + "\"roomType\":\""        + escJson(r.getRoomType())                               + "\","
            + "\"roomNumber\":\""      + escJson(r.getRoomNumber() != null ? r.getRoomNumber() : "") + "\","
            + "\"checkIn\":\""         + r.getCheckIn()                                         + "\","
            + "\"checkOut\":\""        + r.getCheckOut()                                        + "\","
            + "\"nights\":"            + r.getNights()                                           + ","
            + "\"totalAmount\":"       + r.getTotalAmount()
            + "}";
    }

    private String reservationListToJson(List<Reservation> list) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            sb.append(reservationToJson(list.get(i)));
            if (i < list.size() - 1) sb.append(",");
        }
        sb.append("]");
        return sb.toString();
    }

    private String escJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r");
    }
}