require "mail"

class EmailSender
  FROM_EMAIL = "no-reply@camagru.local".freeze
  DOMAIN = ENV.fetch("APP_ENV", "development") != "development" ? "https://camagru.app" : "http://localhost:8000"

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

  def self.send_comment_notification_email(to:, image_url:, image_title:, commenter_username:, comment_content:)
    html = comment_notification_template(
      image_url: image_url,
      image_title: image_title,
      commenter_username: commenter_username,
      comment_content: comment_content
    )

    send_email(
      to: to,
      subject: "New comment on your Camagru image",
      html: html
    )
  end

  # protected agains injections with escape_html
  def self.comment_notification_template(image_url:, image_title:, commenter_username:, comment_content:)
    <<~HTML
      <html>
        <body style="font-family: sans-serif;">
          <h2>Someone commented on your image!</h2>
          <p><strong>#{commenter_username}</strong> wrote:</p>
          <blockquote style="margin: 1em 0; padding: 1em; background: #f9f9f9; border-left: 4px solid #ccc;">
            #{Rack::Utils.escape_html(comment_content)}
          </blockquote>
          <p><strong>Your image:</strong></p>
          <img src="#{image_url}" alt="#{image_title}" style="max-width: 450px; border-radius: 6px; margin-bottom: 1em;" />
          <p>
            <a href="#{DOMAIN}/profile.html" style="background: #3b82f6; color: white; padding: 10px 16px; border-radius: 5px; text-decoration: none;">
              View it on Camagru
            </a>
          </p>
          <p style="font-size: 12px; color: #999;">You received this because you're the owner of the image.</p>
        </body>
      </html>
    HTML
  end

  def self.confirmation_template(token)
    <<~HTML
      <html>
        <body style="font-family: sans-serif;">
          <h2>Welcome to Camagru!</h2>
          <p>Thanks for registering. Please confirm your account:</p>
          <p>
            <a href="#{DOMAIN}/confirm.html?token=#{token}"
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
            <a href="#{DOMAIN}/reset-password.html?token=#{token}"
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
