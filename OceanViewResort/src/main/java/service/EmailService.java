package service;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

/**
 * EmailService – sends OTP emails using Outlook (Office 365) SMTP.
 *
 * SETUP STEPS:
 *  1. Use your Outlook account: OceanViewResortGALLE@outlook.com
 *  2. Put your actual Outlook account password in SENDER_PASSWORD below.
 *  3. Make sure "Less secure app access" or SMTP AUTH is enabled on the account.
 *     (For personal Outlook accounts this works with your normal password.)
 *  4. No App Password needed — unlike Gmail, Outlook uses your regular password.
 */
public class EmailService {

    // ── ✏️  UPDATE THIS PASSWORD ──────────────────────────────────────────────
    private static final String SENDER_EMAIL    = "oceanviewresortgalle@gmail.com";
    private static final String SENDER_PASSWORD = "xorf alrg nncw hmtd"; // ← change this
    // ─────────────────────────────────────────────────────────────────────────

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int    SMTP_PORT = 587;

    /**
     * Sends a 6-digit OTP to the given email address.
     * @return true if sent successfully, false on error
     */
    public static boolean sendOtpEmail(String toEmail, String otpCode) {
        Properties props = new Properties();
        props.put("mail.smtp.auth",                "true");
        props.put("mail.smtp.starttls.enable",     "true");
        props.put("mail.smtp.starttls.required",   "true");  // Required for Office365
        props.put("mail.smtp.host",                SMTP_HOST);
        props.put("mail.smtp.port",                String.valueOf(SMTP_PORT));
        props.put("mail.smtp.ssl.protocols",       "TLSv1.2"); // Office365 requires TLS 1.2
        props.put("mail.smtp.ssl.trust",           SMTP_HOST);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        try {
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(SENDER_EMAIL, "Ocean View Resort"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("Ocean View Resort \u2013 Your Password Reset OTP");
            msg.setContent(buildHtmlBody(otpCode), "text/html; charset=utf-8");
            Transport.send(msg);
            System.out.println("[EmailService] OTP sent successfully to: " + toEmail);
            return true;
        } catch (Exception e) {
            System.err.println("[EmailService] Send failed: " + e.getMessage());
            e.printStackTrace(); // helpful for debugging SMTP issues
            return false;
        }
    }

    /**
     * Overloaded version used by PasswordResetServlet (includes username in email body).
     * @return true if sent successfully, false on error
     */
    public static boolean sendOTPEmail(String toEmail, String otpCode, String username) {
        Properties props = new Properties();
        props.put("mail.smtp.auth",                "true");
        props.put("mail.smtp.starttls.enable",     "true");
        props.put("mail.smtp.starttls.required",   "true");
        props.put("mail.smtp.host",                SMTP_HOST);
        props.put("mail.smtp.port",                String.valueOf(SMTP_PORT));
        props.put("mail.smtp.ssl.protocols",       "TLSv1.2");
        props.put("mail.smtp.ssl.trust",           SMTP_HOST);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });

        try {
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(SENDER_EMAIL, "Ocean View Resort"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("Ocean View Resort \u2013 Your Password Reset OTP");
            msg.setContent(buildHtmlBody(otpCode, username), "text/html; charset=utf-8");
            Transport.send(msg);
            System.out.println("[EmailService] OTP sent successfully to: " + toEmail);
            return true;
        } catch (Exception e) {
            System.err.println("[EmailService] Send failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ── HTML email body (without username) ────────────────────────────────────
    private static String buildHtmlBody(String otpCode) {
        return buildHtmlBody(otpCode, "Admin");
    }

    // ── HTML email body (with username) ──────────────────────────────────────
    private static String buildHtmlBody(String otpCode, String username) {
        return "<!DOCTYPE html><html><head><meta charset='UTF-8'/></head>"
             + "<body style='font-family:Segoe UI,Arial,sans-serif;background:#f4f6f9;margin:0;padding:20px;'>"
             + "<div style='max-width:520px;margin:auto;background:#fff;border-radius:14px;"
             + "box-shadow:0 6px 30px rgba(0,0,0,0.12);overflow:hidden;'>"

             // Header
             + "<div style='background:linear-gradient(135deg,#0a3d62,#1a6b8a);padding:32px 24px;text-align:center;'>"
             + "<div style='font-size:36px;'>&#127958;</div>"
             + "<h2 style='color:#fff;margin:8px 0 4px;font-size:22px;letter-spacing:0.5px;'>Ocean View Resort</h2>"
             + "<p style='color:rgba(255,255,255,0.8);margin:0;font-size:13px;'>Galle, Sri Lanka &ndash; Management System</p>"
             + "</div>"

             // Body
             + "<div style='padding:36px 32px;'>"
             + "<p style='color:#555;'>Hello, <strong>" + username + "</strong></p>"
             + "<h3 style='color:#0a3d62;margin:0 0 12px;'>&#128272; Password Reset OTP</h3>"
             + "<p style='color:#555;line-height:1.6;'>A password reset was requested for your admin account. "
             + "Enter the OTP below within <strong>10 minutes</strong> to reset your password.</p>"

             // OTP box
             + "<div style='background:linear-gradient(135deg,#e8f4f8,#d4ecf7);border:2px solid #1a6b8a;"
             + "border-radius:12px;padding:24px;text-align:center;margin:28px 0;'>"
             + "<p style='color:#0a3d62;font-size:11px;font-weight:700;text-transform:uppercase;"
             + "letter-spacing:2px;margin:0 0 10px;'>One-Time Password</p>"
             + "<div style='font-size:48px;font-weight:900;color:#0a3d62;"
             + "letter-spacing:12px;font-family:Courier New,monospace;'>"
             + otpCode
             + "</div>"
             + "<p style='color:#e74c3c;font-size:12px;margin:12px 0 0;font-weight:600;'>"
             + "&#9200; Expires in 10 minutes</p>"
             + "</div>"

             // Warning
             + "<div style='background:#fff8e1;border-left:4px solid #f39c12;border-radius:6px;"
             + "padding:12px 16px;margin-bottom:20px;'>"
             + "<p style='color:#856404;font-size:12px;margin:0;'>"
             + "<strong>&#9888;&#65039; Security Notice:</strong> If you did not request this, "
             + "please contact IT support immediately and do not share this OTP with anyone.</p>"
             + "</div>"

             + "<hr style='border:none;border-top:1px solid #eee;margin:20px 0;'/>"
             + "<p style='color:#aaa;font-size:11px;text-align:center;margin:0;'>"
             + "Ocean View Resort &nbsp;&middot;&nbsp; Galle, Sri Lanka<br/>"
             + "Sent from: OceanViewResortGALLE@outlook.com<br/>"
             + "This is an automated message. Do not reply.</p>"
             + "</div></div></body></html>";
    }
}