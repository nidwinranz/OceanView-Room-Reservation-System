package util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * AuthGuard – session-based access control helpers.
 */
public class AuthGuard {

    /**
     * Returns true if the logged-in user is an ADMIN.
     * Redirects to /login if not logged in, or /access-denied if not admin.
     */
    public static boolean isAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        String role = (String) session.getAttribute("userRole");
        if (!"ADMIN".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/access-denied");
            return false;
        }
        return true;
    }

    /**
     * Returns true if the logged-in user is STAFF or ADMIN (any logged-in user).
     * Redirects to /login if not logged in.
     */
    public static boolean isLoggedIn(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    /**
     * Returns the username of the currently logged-in user, or null if not logged in.
     */
    public static String getUsername(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (String) session.getAttribute("loggedInUser");
    }

    /**
     * Returns the role of the currently logged-in user, or null if not logged in.
     */
    public static String getRole(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (String) session.getAttribute("userRole");
    }
}
