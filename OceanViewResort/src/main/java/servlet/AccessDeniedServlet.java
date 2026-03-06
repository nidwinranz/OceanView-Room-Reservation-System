package servlet;

import util.AuthGuard;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/** Shows access denied page when a STAFF tries to access ADMIN-only pages. */
@WebServlet(name = "AccessDeniedServlet", urlPatterns = "/access-denied")
public class AccessDeniedServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!AuthGuard.isLoggedIn(req, resp)) return;
        req.getRequestDispatcher("/jsp/accessDenied.jsp").forward(req, resp);
    }
}
