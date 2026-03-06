package servlet;

import dao.UserDAO;
import dao.UserDAOImpl;
import model.User;
import util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * LoginServlet – handles login and saves role to session.
 *
 * After login, session stores:
 *   "loggedInUser" → username (String)
 *   "userRole"     → "ADMIN" or "STAFF" (String)
 *   "userId"       → user id (Integer)
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login", ""})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Already logged in → go to dashboard
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("loggedInUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }
        req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = ValidationUtil.sanitize(req.getParameter("username"));
        String password = req.getParameter("password");

        if (ValidationUtil.isEmpty(username) || ValidationUtil.isEmpty(password)) {
            req.setAttribute("error", "Username and password are required.");
            req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.authenticate(username, password);

        if (user != null) {
            // ── Create session and store role ─────────────────────────────────
            HttpSession session = req.getSession(true);
            session.setAttribute("loggedInUser", user.getUsername());
            session.setAttribute("userRole",     user.getRole());   // "ADMIN" or "STAFF"
            session.setAttribute("userId",       user.getId());
            session.setMaxInactiveInterval(30 * 60); // 30 minutes
            // ─────────────────────────────────────────────────────────────────

            resp.sendRedirect(req.getContextPath() + "/dashboard");
        } else {
            req.setAttribute("error", "Invalid username or password. Please try again.");
            req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
        }
    }
}
