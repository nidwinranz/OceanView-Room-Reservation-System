package servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import dao.UserDAO;
import dao.UserDAOImpl;
import model.User;
import util.ValidationUtil;
import java.io.IOException;

/**
 * LoginServlet – handles GET (show form) and POST (authenticate).
 *
 * MVC Role: Controller – receives HTTP request, calls Model/DAO,
 *           forwards to appropriate View (JSP).
 *
 * Security:
 *  • Input is sanitized before use.
 *  • Session is created only on successful login.
 *  • Session is invalidated on logout.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login", ""})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // If already logged in, go straight to dashboard
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
        String password = req.getParameter("password");   // not sanitized so special chars work

        if (ValidationUtil.isEmpty(username) || ValidationUtil.isEmpty(password)) {
            req.setAttribute("error", "Username and password are required.");
            req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.authenticate(username, password);

        if (user != null) {
            // ── Create session ────────────────────────────────────────────────
            HttpSession session = req.getSession(true);
            session.setAttribute("loggedInUser", user.getUsername());
            session.setMaxInactiveInterval(30 * 60); // 30 minutes
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        } else {
            req.setAttribute("error", "Invalid username or password. Please try again.");
            req.getRequestDispatcher("/jsp/login.jsp").forward(req, resp);
        }
    }
}
