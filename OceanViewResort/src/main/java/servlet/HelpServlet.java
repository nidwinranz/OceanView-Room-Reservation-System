package servlet;

import util.AuthGuard;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "HelpServlet", urlPatterns = "/help")
public class HelpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!AuthGuard.isLoggedIn(req, resp)) return;  // any logged-in user
        req.getRequestDispatcher("/jsp/help.jsp").forward(req, resp);
    }
}
