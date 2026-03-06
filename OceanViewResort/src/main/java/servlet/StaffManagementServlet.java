package servlet;

import dao.UserDAO;
import dao.UserDAOImpl;
import model.User;
import util.AuthGuard;
import util.ValidationUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * StaffManagementServlet – ADMIN ONLY
 * ─────────────────────────────────────
 * GET  /staff              → show all staff list + register form
 * POST /staff?action=add   → register new staff member
 * POST /staff?action=delete → delete a staff member
 *
 * Non-admin users are redirected to /access-denied automatically.
 */
@WebServlet(name = "StaffManagementServlet", urlPatterns = "/staff")
public class StaffManagementServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAOImpl();

    // ── GET – Show staff list and registration form ───────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ADMIN ONLY guard
        if (!AuthGuard.isAdmin(req, resp)) return;

        List<User> staffList = userDAO.getAllStaff();
        req.setAttribute("staffList", staffList);
        req.setAttribute("staffCount", staffList.size());
        req.getRequestDispatcher("/jsp/manageStaff.jsp").forward(req, resp);
    }

    // ── POST – Handle add or delete ───────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ADMIN ONLY guard
        if (!AuthGuard.isAdmin(req, resp)) return;

        String action = req.getParameter("action");

        if ("add".equals(action)) {
            handleAddStaff(req, resp);
        } else if ("delete".equals(action)) {
            handleDeleteStaff(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/staff");
        }
    }

    // ── Add Staff ─────────────────────────────────────────────────────────────
    private void handleAddStaff(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username        = ValidationUtil.sanitize(req.getParameter("username"));
        String password        = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // ── Validation ────────────────────────────────────────────────────────
        String error = null;

        if (ValidationUtil.isEmpty(username)) {
            error = "Username is required.";
        } else if (username.length() < 3) {
            error = "Username must be at least 3 characters.";
        } else if (!username.matches("[a-zA-Z0-9_]+")) {
            error = "Username can only contain letters, numbers, and underscores.";
        } else if (ValidationUtil.isEmpty(password)) {
            error = "Password is required.";
        } else if (password.length() < 6) {
            error = "Password must be at least 6 characters.";
        } else if (!password.equals(confirmPassword)) {
            error = "Passwords do not match.";
        } else if (userDAO.usernameExists(username)) {
            error = "Username '" + username + "' is already taken. Choose another.";
        }

        if (error != null) {
            // Re-show form with error
            req.setAttribute("error", error);
            req.setAttribute("v_username", username);
            List<User> staffList = userDAO.getAllStaff();
            req.setAttribute("staffList", staffList);
            req.setAttribute("staffCount", staffList.size());
            req.getRequestDispatcher("/jsp/manageStaff.jsp").forward(req, resp);
            return;
        }

        // ── Save to database ──────────────────────────────────────────────────
        boolean success = userDAO.registerStaff(username, password);

        if (success) {
            req.setAttribute("successMsg", "Staff member '" + username + "' registered successfully!");
        } else {
            req.setAttribute("error", "Failed to register staff. Please try again.");
        }

        List<User> staffList = userDAO.getAllStaff();
        req.setAttribute("staffList", staffList);
        req.setAttribute("staffCount", staffList.size());
        req.getRequestDispatcher("/jsp/manageStaff.jsp").forward(req, resp);
    }

    // ── Delete Staff ──────────────────────────────────────────────────────────
    private void handleDeleteStaff(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idStr = req.getParameter("userId");

        try {
            int userId = Integer.parseInt(idStr);
            boolean deleted = userDAO.deleteUser(userId);

            if (deleted) {
                req.setAttribute("successMsg", "Staff member removed successfully.");
            } else {
                req.setAttribute("error", "Could not remove staff member. Admin accounts cannot be deleted.");
            }
        } catch (NumberFormatException e) {
            req.setAttribute("error", "Invalid user ID.");
        }

        List<User> staffList = userDAO.getAllStaff();
        req.setAttribute("staffList", staffList);
        req.setAttribute("staffCount", staffList.size());
        req.getRequestDispatcher("/jsp/manageStaff.jsp").forward(req, resp);
    }
}
