require_relative "./base_controller"
require_relative "../models/user"
require_relative "../models/password_reset_token"
require_relative "../helpers/password_hasher"
require_relative "../lib/email_sender"

class PasswordResetsController < BaseController
  api_doc "/password/forgot", method: :post do
    description(
      "Request a password reset link." \
      "If the email exists, a reset token is sent." \
      "The response is always generic to prevent user enumeration."
    )
    tags "password", "reset"
    auth_required value: false

    param :email, String, required: true, desc: "The email address of the user requesting a password reset."

    response 200, "Reset link sent (if account exists)", example: {
      message: "If your email exists, a reset link has been sent"
    }

    response 400, "Missing email", example: {
      error: "Missing email"
    }
  end

  post "/password/forgot" do
    data = json_body
    email = data["email"].to_s.strip
    halt 400, json_error("Missing email") if email.empty?

    user = User.find_by_email(email)

    if user
      token = SecureRandom.hex(20)
      expires_at = Time.now + (60 * 60 * 2) # 2 hours
      PasswordResetToken.create(user_id: user["id"], token: token, expires_at: expires_at)
      EmailSender.send_password_reset_email(email: user["email"], token: token)
    end

    # Always return 200 to avoid email enumeration
    json_response({message: "If your email exists, a reset link has been sent"})
  end

  api_doc "/password/reset", method: :post do
    description(
      "Request a password reset link. If the email exists, a reset token is sent." \
      "The response is always generic to prevent user enumeration."
    )
    tags "password", "reset"
    auth_required value: false

    param :token, String, required: true, desc: "Reset token received by email"
    param :password, String, required: true, desc: "New password (minimum 8 characters)"

    response 200, "Password reset successfully", example: {
      message: "Password reset successfully"
    }

    response 400, "Missing token or password", example: {
      error: "Missing token or password"
    }

    response 400, "Password too short", example: {
      error: "Password too short (min 8 chars)"
    }

    response 400, "Invalid or expired token", example: {
      error: "Invalid or expired token"
    }
  end

  post "/password/reset" do
    data = json_body
    token = data["token"].to_s.strip
    new_password = data["password"].to_s

    halt 400, json_error("Missing token or password") if token.empty? || new_password.empty?
    halt 400, json_error("Password too short (min 8 chars)") if new_password.length < 8

    reset = PasswordResetToken.find_valid(token)
    halt 400, json_error("Invalid or expired token") unless reset

    User.update_password!(reset["user_id"], new_password)
    PasswordResetToken.delete_by_token(token)

    json_response({message: "Password reset successfully"})
  end
end
