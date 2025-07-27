require_relative "../helpers/password_hasher"
require_relative "./base_controller"
require_relative "../models/user"

class SessionsController < BaseController
  api_doc "/login", method: :post do
    description "Authenticate a user using either username or email. Returns a session token on success."
    tags "auth", "sessions"
    auth_required value: false

    param :identity, String, required: true, desc: "Username or email address"
    param :password, String, required: true, desc: "User's password"

    response 200, "Login successful", example: {
      token: "<jwt_token_here>"
    }

    response 400, "Missing identity or password", example: {
      error: "Missing identity or password"
    }

    response 401, "Invalid credentials", example: {
      error: "Invalid credentials"
    }
  end

  post "/login" do
    data     = json_body
    identity = data["identity"]
    password = data["password"]

    halt 400, json_error("Missing identity or password") if identity.to_s.strip.empty? || password.to_s.strip.empty?

    user = User.find_by_email(identity) || User.find_by_username(identity)
    halt 401, json_error("Invalid credentials") unless user

    halt 401, json_error("Invalid credentials") unless PasswordHasher.valid_password?(password, user["password_hash"])

    token = SessionToken.generate(user["id"])
    json_response({token: token})
  end

  api_doc "/logout", method: :post do
    description "Invalidate current session token. For JWT-based apps, the client must delete the token locally."
    tags "auth", "sessions"
    auth_required value: true

    response 200, "Logout successful", example: {
      message: "Logged out successfully"
    }
  end

  post "/logout" do
    json_response({message: "Logged out successfully"})
  end
end
