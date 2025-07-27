require_relative "./base_controller"
require_relative "../models/user"
require_relative "../models/email_confirmation"
require_relative "../helpers/password_hasher"
require_relative "../lib/email_sender"

class UsersController < BaseController
  api_doc "/signup", method: :post do
    description "Register a new user. Sends a confirmation email with a validation token."
    tags "auth", "users"
    auth_required value: false

    param :username, String, required: true, desc: "Unique username"
    param :email, String, required: true, desc: "Valid email address"
    param :password, String, required: true, desc: "Minimum 8 characters"

    response 201, "User created", example: {
      message: "Confirmation email sent"
    }

    response 400, "Validation failed", example: {
      error: "All fields are required"
    }

    response 400, "Validation failed", example: {
      error: "Invalid email format"
    }

    response 400, "Validation failed", example: {
      error: "Password too short (min 8 chars)"
    }

    response 400, "Validation failed", example: {
      error: "Username already registered"
    }

    response 400, "Validation failed", example: {
      error: "Email already registered"
    }
  end

  post "/signup" do
    data = json_body
    username = data["username"]
    email    = data["email"]
    password = data["password"]

    halt 400, json_error("All fields are required") if [username, email, password].any? { _1.to_s.strip.empty? }
    halt 400, json_error("Invalid email format") unless email.match?(/\A[^@\s]+@[^@\s]+\z/)
    halt 400, json_error("Password too short (min 8 chars)") if password.length < 8

    halt 400, json_error("Username already taken") if User.find_by_username(username)
    halt 400, json_error("Email already registered") if User.find_by_email(email)

    user = User.create(username: username, email: email, password: password)

    token = SecureRandom.hex(16)
    EmailConfirmation.create(user_id: user["id"], token: token)
    EmailSender.send_confirmation_email(email: user["email"], token:)

    status 201
    json_response({message: "Confirmation email sent"}, status: 201)
  end

  api_doc "/confirm", method: :get do
    description "Confirm user email using the token sent during registration."
    tags "auth", "email"
    auth_required value: false

    param :token, String, required: true, desc: "Confirmation token sent via email"

    response 200, "Email confirmed", example: {
      message: "Email confirmed successfully!"
    }

    response 400, "Invalid or missing token", example: {
      error: "Invalid or expired token"
    }
  end

  get "/confirm" do
    token = params["token"].to_s.strip
    halt 400, json_error("Missing token") if token.empty?

    record = EmailConfirmation.find_by_token(token)
    halt 400, json_error("Invalid or expired token") unless record

    User.confirm_email!(record["user_id"])
    EmailConfirmation.delete_by_token(token)

    json_response({message: "Email confirmed successfully!"})
  end
end
