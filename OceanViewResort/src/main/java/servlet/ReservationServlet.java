package servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Reservation;
import service.ReservationService;
import util.ValidationUtil;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ReservationServlet", urlPatterns = "/reservation")
public class ReservationServlet extends HttpServlet {

    private final ReservationService svc = new ReservationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) action = "add";

        // ── AJAX: available rooms ─────────────────────────────────────────────
        if ("availableRooms".equals(action)) {
            String roomType = req.getParameter("roomType");
            String checkIn  = req.getParameter("checkIn");
            String checkOut = req.getParameter("checkOut");
            List<String> rooms = svc.getAvailableRooms(roomType, checkIn, checkOut);
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < rooms.size(); i++) {
                if (i > 0) json.append(",");
                json.append("\"").append(rooms.get(i)).append("\"");
            }
            json.append("]");
            System.out.println("[ReservationServlet] availableRooms JSON: " + json);
            resp.getWriter().write(json.toString());
            return;
        }

        // ── AJAX: guest lookup by national ID ─────────────────────────────────
        if ("guestLookup".equals(action)) {
            String nationalId = req.getParameter("nationalId");
            Reservation r = svc.getGuestByNationalId(nationalId);
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            if (r != null) {
                resp.getWriter().write("{" +
                    "\"found\":true," +
                    "\"guestName\":\"" + esc(r.getGuestName()) + "\"," +
                    "\"address\":\""   + esc(r.getAddress())     + "\"," +
                    "\"contactNumber\":\"" + esc(r.getContactNumber()) + "\"," +
                    "\"email\":\""     + esc(r.getEmail() != null ? r.getEmail() : "") + "\"," +
                    "\"isVip\":"       + r.isVip() +
                "}");
            } else {
                resp.getWriter().write("{\"found\":false}");
            }
            return;
        }

        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        switch (action) {

            // ── View single reservation + always pass full list ───────────────
            case "view": {
                // Always load all reservations so the list panel is populated
                req.setAttribute("allReservations", svc.getAllReservations());

                String id = ValidationUtil.sanitize(req.getParameter("id"));
                if (!ValidationUtil.isEmpty(id)) {
                    Reservation r = svc.getReservationById(id);
                    if (r != null) {
                        req.setAttribute("reservation", r);
                    } else {
                        req.setAttribute("error", "No reservation found with ID: " + id);
                    }
                }
                req.getRequestDispatcher("/jsp/viewReservation.jsp").forward(req, resp);
                break;
            }

            // ── List all reservations ─────────────────────────────────────────
            case "list": {
                req.setAttribute("reservations", svc.getAllReservations());
                req.getRequestDispatcher("/jsp/listReservations.jsp").forward(req, resp);
                break;
            }

            // ── Edit reservation ──────────────────────────────────────────────
            case "edit": {
                String id = ValidationUtil.sanitize(req.getParameter("id"));
                Reservation r = svc.getReservationById(id);
                if (r != null) req.setAttribute("reservation", r);
                else req.setAttribute("error", "Reservation not found.");
                req.getRequestDispatcher("/jsp/editReservation.jsp").forward(req, resp);
                break;
            }

            // ── Delete reservation ────────────────────────────────────────────
            case "delete": {
                String id = ValidationUtil.sanitize(req.getParameter("id"));
                svc.deleteReservation(id);
                resp.sendRedirect(req.getContextPath() + "/reservation?action=view&msg=deleted");
                break;
            }

            // ── Default: Add reservation form ─────────────────────────────────
            default: {
                req.setAttribute("nextResId", svc.getNextReservationId());
                req.getRequestDispatcher("/jsp/addReservation.jsp").forward(req, resp);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String action = req.getParameter("action");

        if ("add".equals(action)) {
            String resId         = req.getParameter("reservationId");
            String guestName     = req.getParameter("guestName");
            String address       = req.getParameter("address");
            String contactNumber = req.getParameter("contactNumber");
            String email         = req.getParameter("email");
            String nationalId    = req.getParameter("nationalId");
            String numAdults     = req.getParameter("numAdults");
            String numChildren   = req.getParameter("numChildren");
            String specialReqs   = req.getParameter("specialRequests");
            String roomType      = req.getParameter("roomType");
            String roomNumber    = req.getParameter("roomNumber");
            String checkIn       = req.getParameter("checkIn");
            String checkOut      = req.getParameter("checkOut");

            String error = svc.addReservation(resId, guestName, address, contactNumber,
                email, nationalId, numAdults, numChildren, specialReqs,
                roomType, roomNumber, checkIn, checkOut);

            if (error == null) {
                resp.sendRedirect(req.getContextPath() + "/bill?id=" + resId);
            } else {
                req.setAttribute("error",         error);
                req.setAttribute("nextResId",      resId);
                req.setAttribute("v_name",         guestName);
                req.setAttribute("v_address",      address);
                req.setAttribute("v_phone",        contactNumber);
                req.setAttribute("v_email",        email);
                req.setAttribute("v_nationalId",   nationalId);
                req.setAttribute("v_numAdults",    numAdults);
                req.setAttribute("v_numChildren",  numChildren);
                req.setAttribute("v_specialReqs",  specialReqs);
                req.setAttribute("v_room",         roomType);
                req.setAttribute("v_roomNumber",   roomNumber);
                req.setAttribute("v_in",           checkIn);
                req.setAttribute("v_out",          checkOut);
                req.getRequestDispatcher("/jsp/addReservation.jsp").forward(req, resp);
            }
        }

        else if ("edit".equals(action)) {
            String resId         = req.getParameter("reservationId");
            String guestName     = req.getParameter("guestName");
            String address       = req.getParameter("address");
            String contactNumber = req.getParameter("contactNumber");
            String email         = req.getParameter("email");
            String nationalId    = req.getParameter("nationalId");
            String numAdults     = req.getParameter("numAdults");
            String numChildren   = req.getParameter("numChildren");
            String specialReqs   = req.getParameter("specialRequests");
            String roomType      = req.getParameter("roomType");
            String roomNumber    = req.getParameter("roomNumber");
            String checkIn       = req.getParameter("checkIn");
            String checkOut      = req.getParameter("checkOut");

            String error = svc.updateReservation(resId, guestName, address, contactNumber,
                email, nationalId, numAdults, numChildren, specialReqs,
                roomType, roomNumber, checkIn, checkOut);

            if (error == null) {
                resp.sendRedirect(req.getContextPath() + "/reservation?action=view&id=" + resId + "&msg=updated");
            } else {
                Reservation r = svc.getReservationById(resId);
                req.setAttribute("reservation", r);
                req.setAttribute("allReservations", svc.getAllReservations());
                req.setAttribute("error", error);
                req.getRequestDispatcher("/jsp/editReservation.jsp").forward(req, resp);
            }
        }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("loggedInUser") != null;
    }
}
