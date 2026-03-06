package servlet;

import service.ReservationService;
import util.AuthGuard;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * DashboardServlet – shows different content based on role.
 * ADMIN sees: full stats + staff count + all reports link
 * STAFF sees: limited stats (no income, no staff management)
 */
@WebServlet(name = "DashboardServlet", urlPatterns = "/dashboard")
public class DashboardServlet extends HttpServlet {

    private final ReservationService svc = new ReservationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!AuthGuard.isLoggedIn(req, resp)) return;

        String role = AuthGuard.getRole(req);

        // Both roles see these stats
        req.setAttribute("totalReservations", svc.getAllReservations().size());
        req.setAttribute("activeCount",       svc.getActiveReservations().size());

        // ADMIN only stats
        if ("ADMIN".equals(role)) {
            req.setAttribute("totalIncome", svc.getTotalIncome());
        }

        req.getRequestDispatcher("/jsp/dashboard.jsp").forward(req, resp);
    }
}
