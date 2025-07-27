require "spec_helper"
require_relative "../../app/models/password_reset_token"
require_relative "../../app/models/user"

# rubocop:disable Metrics/BlockLength

RSpec.describe PasswordResetToken do
  let(:user) do
    User.create(
      username: "testuser_#{SecureRandom.hex(2)}",
      email: "testuser_#{SecureRandom.hex(3)}@example.com",
      password: "SuperSafe123"
    )
  end

  describe ".create" do
    it "creates a reset token for a user" do
      token = SecureRandom.hex(16)
      expires_at = Time.now + 3600

      PasswordResetToken.create(user_id: user["id"], token: token, expires_at: expires_at)

      result = PasswordResetToken.query("SELECT * FROM password_reset_tokens WHERE token = $1", [token])
      expect(result.ntuples).to eq(1)
      expect(result[0]["user_id"].to_i).to eq(user["id"].to_i)
    end
  end

  describe ".find_valid" do
    it "returns the token if it exists and is not expired" do
      token = SecureRandom.hex(16)
      PasswordResetToken.create(user_id: user["id"], token: token, expires_at: Time.now + 600)

      found = PasswordResetToken.find_valid(token)
      expect(found).not_to be_nil
      expect(found["token"]).to eq(token)
    end

    it "returns nil if token does not exist" do
      expect(PasswordResetToken.find_valid("nonexistent")).to be_nil
    end

    it "returns nil if token is expired" do
      token = SecureRandom.hex(16)
      PasswordResetToken.create(user_id: user["id"], token: token, expires_at: Time.now - 60)

      expect(PasswordResetToken.find_valid(token)).to be_nil
    end
  end

  describe ".delete_by_token" do
    it "removes the reset token" do
      token = SecureRandom.hex(16)
      PasswordResetToken.create(user_id: user["id"], token: token, expires_at: Time.now + 600)

      PasswordResetToken.delete_by_token(token)
      expect(PasswordResetToken.find_valid(token)).to be_nil
    end
  end
end
# rubocop:enable Metrics/BlockLength
