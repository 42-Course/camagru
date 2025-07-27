require "mail"

class EmailSender
  FROM_EMAIL = "no-reply@camagru.local".freeze
  DOMAIN = ENV.fetch("APP_ENV", "development") != "development" ? "https://camagru.app" : "http://localhost:5173"

  def self.setup
    Mail.defaults do
      delivery_method :smtp, {
        address: ENV.fetch("SMTP_ADDRESS", "localhost"),
        port: ENV.fetch("SMTP_PORT", 1025),
        user_name: ENV.fetch("SMTP_USERNAME", nil),
        password: ENV.fetch("SMTP_PASSWORD", nil),
        authentication: :plain,
        enable_starttls_auto: true
      }
    end
  end

  def self.send_email(to:, subject:, html:)
    setup
    Mail.deliver do
      from     FROM_EMAIL
      to       to
      subject  subject

      html_part do
        content_type "text/html; charset=UTF-8"
        body html
      end
    end
  rescue StandardError => e
    warn "❌ Email failed to #{to} — #{e.class}: #{e.message}"
  end

  def self.send_confirmation_email(email:, token:)
    html = confirmation_template(token)
    send_email(to: email, subject: "Confirm your Camagru account", html: html)
  end

  def self.send_password_reset_email(email:, token:)
    html = reset_password_template(token)
    send_email(to: email, subject: "Reset your Camagru password", html: html)
  end

  def self.confirmation_template(token)
    <<~HTML
      <html>
        <body style="font-family: sans-serif;">
          <h2>Welcome to Camagru!</h2>
          <p>Thanks for registering. Please confirm your account:</p>
          <p>
            <a href="#{DOMAIN}/confirm?token=#{token}"
               style="background: #22c55e; color: white; padding: 10px 16px; border-radius: 5px; text-decoration: none;">
              Confirm My Account
            </a>
          </p>
          <p style="font-size: 12px; color: #999;">If you did not sign up, you can ignore this email.</p>
        </body>
      </html>
    HTML
  end

  def self.reset_password_template(token)
    <<~HTML
      <html>
        <body style="font-family: sans-serif;">
          <h2>Reset Your Password</h2>
          <p>Click the button below to reset your Camagru password:</p>
          <p>
            <a href="#{DOMAIN}/reset-password?token=#{token}"
               style="background: #ef4444; color: white; padding: 10px 16px; border-radius: 5px; text-decoration: none;">
              Reset Password
            </a>
          </p>
          <p style="font-size: 12px; color: #999;">If you didn’t request this, you can safely ignore it.</p>
        </body>
      </html>
    HTML
  end
end
