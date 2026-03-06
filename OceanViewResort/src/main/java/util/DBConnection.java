package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection – Singleton Pattern
 * ---------------------------------
 * Ensures only ONE database connection instance exists throughout the
 * application lifecycle. This saves resources and avoids connection leaks.
 *
 * Design Pattern: Singleton
 * Why: A single, shared JDBC connection avoids the overhead of repeatedly
 *      opening/closing connections and guarantees consistent state access.
 */
public class DBConnection {

    // ── Singleton instance ──────────────────────────────────────────────────
    private static DBConnection instance = null;
    private Connection connection = null;

    // ── Database credentials ────────────────────────────────────────────────
    private static final String DB_URL      = "jdbc:mysql://localhost:3306/oceanview_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String DB_USER     = "root";
    private static final String DB_PASSWORD = "";          // change to your MySQL root password
    private static final String DB_DRIVER   = "com.mysql.cj.jdbc.Driver";

    // ── Private constructor (no direct instantiation) ───────────────────────
    private DBConnection() {
        try {
            Class.forName(DB_DRIVER);
            this.connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("[DBConnection] MySQL connection established successfully.");
        } catch (ClassNotFoundException e) {
            System.err.println("[DBConnection] MySQL JDBC Driver not found: " + e.getMessage());
            throw new RuntimeException("MySQL driver not found", e);
        } catch (SQLException e) {
            System.err.println("[DBConnection] Connection failed: " + e.getMessage());
            throw new RuntimeException("Database connection failed", e);
        }
    }

    /**
     * Returns the single DBConnection instance (thread-safe).
     */
    public static synchronized DBConnection getInstance() {
        if (instance == null || isConnectionClosed()) {
            instance = new DBConnection();
        }
        return instance;
    }

    /**
     * Returns the underlying java.sql.Connection object.
     */
    public Connection getConnection() {
        return connection;
    }

    /**
     * Checks whether the connection has been closed or is invalid.
     */
    private static boolean isConnectionClosed() {
        try {
            return instance == null || instance.connection == null || instance.connection.isClosed();
        } catch (SQLException e) {
            return true;
        }
    }
}
