require_relative "../helpers/password_hasher"
require_relative "./base_controller"
require_relative "../models/user"

class SessionsController < BaseController
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
end
