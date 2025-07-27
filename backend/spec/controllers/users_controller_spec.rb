require "spec_helper"
require_relative "../../app/controllers/users_controller"
require_relative "../../app/models/user"
require_relative "../../app/models/email_confirmation"
require_relative "../../app/helpers/password_hasher"

# rubocop:disable Metrics/BlockLength
RSpec.describe UsersController do
  let(:username) { "user_#{SecureRandom.hex(2)}" }
  let(:email) { "user_#{SecureRandom.hex(4)}@example.com" }
  let(:password) { "supersecure123" }

  describe "POST /signup" do
    it "creates a new user and confirmation token" do
      expect(EmailConfirmation).to receive(:create).and_call_original

      post "/signup",
           {username: username, email: email, password: password}.to_json,
           {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(201)

      json = JSON.parse(last_response.body)
      expect(json["message"]).to eq("Confirmation email sent")

      user = User.find_by_email(email)
      expect(user).not_to be_nil

      confirmation = EmailConfirmation.query("SELECT * FROM email_confirmations WHERE user_id = $1", [user["id"]])
      expect(confirmation.ntuples).to eq(1)
    end

    it "fails if required fields are missing" do
      post "/signup",
           {username: "", email: "", password: ""}.to_json,
           {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)["error"]).to match(/All fields are required/)
    end

    it "fails if email is invalid" do
      post "/signup",
           {username: username, email: "bademail", password: password}.to_json,
           {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)["error"]).to match(/Invalid email format/)
    end

    it "fails if password is too short" do
      post "/signup",
           {username: username, email: email, password: "short"}.to_json,
           {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)["error"]).to match(/Password too short/)
    end

    it "fails if username already exists" do
      User.create(username: username, email: "unique1@example.com", password: password)

      post "/signup",
           {username: username, email: email, password: password}.to_json,
           {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)["error"]).to match(/Username already taken/)
    end

    it "fails if email already exists" do
      User.create(username: "unique_#{username}", email: email, password: password)

      post "/signup",
           {username: username, email: email, password: password}.to_json,
           {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)["error"]).to match(/Email already registered/)
    end
  end

  describe "GET /confirm" do
    let(:token) { SecureRandom.hex(12) }

    it "confirms the user if the token is valid" do
      user = User.create(username: "cf_#{SecureRandom.hex(2)}", email: "cf_#{SecureRandom.hex(3)}@example.com",
                         password: "secure123")
      EmailConfirmation.create(user_id: user["id"], token: token)

      get "/confirm?token=#{token}"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json["message"]).to eq("Email confirmed successfully!")

      updated = User.find_by_id(user["id"])
      expect(updated["confirmed_at"]).not_to be_nil

      remaining_token = EmailConfirmation.find_by_token(token)
      expect(remaining_token).to be_nil
    end

    it "returns 400 if the token is missing" do
      get "/confirm"
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)["error"]).to match(/Missing token/)
    end

    it "returns 400 if the token is invalid" do
      get "/confirm?token=invalid123"
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)["error"]).to match(/Invalid or expired/)
    end
  end
end
# rubocop:enable Metrics/BlockLength
