package servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Reservation;
import service.ReservationService;
import util.ValidationUtil;
import java.io.IOException;

/** Fetches a reservation by ID and forwards to the bill JSP. */
@WebServlet(name = "BillServlet", urlPatterns = "/bill")
public class BillServlet extends HttpServlet {

    private final ReservationService svc = new ReservationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!isLoggedIn(req)) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String id = ValidationUtil.sanitize(req.getParameter("id"));

        if (ValidationUtil.isEmpty(id)) {
            resp.sendRedirect(req.getContextPath() + "/reservation?action=view");
            return;
        }

        Reservation r = svc.getReservationById(id);
        if (r == null) {
            req.setAttribute("error", "Reservation not found: " + id);
            req.getRequestDispatcher("/jsp/viewReservation.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("reservation", r);
        req.getRequestDispatcher("/jsp/bill.jsp").forward(req, resp);
    }

    private boolean isLoggedIn(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s != null && s.getAttribute("loggedInUser") != null;
    }
}
