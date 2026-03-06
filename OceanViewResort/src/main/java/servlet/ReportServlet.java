package servlet;

import model.Reservation;
import service.ReservationService;
import util.AuthGuard;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * ReportServlet – ADMIN ONLY.
 * Staff members who try to access /report are redirected to access-denied.
 */
@WebServlet(name = "ReportServlet", urlPatterns = "/report")
public class ReportServlet extends HttpServlet {

    private final ReservationService svc = new ReservationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ADMIN ONLY
        if (!AuthGuard.isAdmin(req, resp)) return;

        List<Reservation> all    = svc.getAllReservations();
        List<Reservation> active = svc.getActiveReservations();
        Map<String,Long>  byRoom = svc.getCountByRoomType();
        double            income = svc.getTotalIncome();

        req.setAttribute("allReservations",    all);
        req.setAttribute("activeReservations", active);
        req.setAttribute("byRoomType",         byRoom);
        req.setAttribute("totalIncome",        income);

        req.getRequestDispatcher("/jsp/report.jsp").forward(req, resp);
    }
}
