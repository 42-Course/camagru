require "spec_helper"
require_relative "../../app/models/user"
require_relative "../../app/models/password_reset_token"
require_relative "../../app/controllers/password_resets_controller"
require_relative "../../app/helpers/password_hasher"

# rubocop:disable Metrics/BlockLength
RSpec.describe PasswordResetsController do
  let(:email) { "reset_#{SecureRandom.hex(2)}@example.com" }
  let(:password) { "SuperSecure123" }
  let(:user) do
    User.create(username: "resetuser_#{SecureRandom.hex(2)}", email: email, password: password)
  end

  describe "POST /password/forgot" do
    it "returns 200 even if email does not exist" do
      post "/password/forgot", {email: "nonexistent@example.com"}.to_json, {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)["message"]).to match(/reset link has been sent/i)
    end

    it "creates a reset token if email exists" do
      post "/password/forgot", {email: user["email"]}.to_json, {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(200)

      tokens = PasswordResetToken.query("SELECT * FROM password_reset_tokens WHERE user_id = $1", [user["id"]])
      expect(tokens.ntuples).to eq(1)
    end

    it "returns 400 for missing email" do
      post "/password/forgot", {}.to_json, {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)["error"]).to match(/missing email/i)
    end
  end

  describe "POST /password/reset" do
    let(:token) { SecureRandom.hex(12) }
    let(:new_password) { "NewPass1234" }

    before do
      PasswordResetToken.create(user_id: user["id"], token: token, expires_at: Time.now + 3600)
    end

    it "resets password with valid token" do
      post "/password/reset",
           {token: token, password: new_password}.to_json,
           {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)["message"]).to eq("Password reset successfully")

      updated = User.find_by_id(user["id"])
      expect(PasswordHasher.valid_password?(new_password, updated["password_hash"])).to be true
    end

    it "returns 400 for invalid token" do
      post "/password/reset",
           {token: "invalidtoken", password: new_password}.to_json,
           {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)["error"]).to match(/invalid or expired/i)
    end

    it "returns 400 for short password" do
      post "/password/reset",
           {token: token, password: "123"}.to_json,
           {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)["error"]).to match(/too short/i)
    end

    it "returns 400 for missing fields" do
      post "/password/reset",
           {}.to_json,
           {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)["error"]).to match(/missing token or password/i)
    end
  end
end
# rubocop:enable Metrics/BlockLength
