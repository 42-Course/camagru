require "spec_helper"
require_relative "../../app/models/email_confirmation"
require_relative "../../app/models/user"
require_relative "../../app/helpers/password_hasher"

# rubocop:disable Metrics/BlockLength
RSpec.describe EmailConfirmation do
  let(:user) do
    User.create(
      username: "testuser_#{SecureRandom.hex(2)}",
      email: "test_#{SecureRandom.hex(3)}@example.com",
      password: "securePass123"
    )
  end

  describe ".create" do
    it "creates a confirmation record for a user with a token" do
      token = SecureRandom.hex(16)
      record = EmailConfirmation.create(user_id: user["id"], token: token)

      expect(record).to include(
        "user_id" => user["id"],
        "token" => token
      )
      expect(record["created_at"]).not_to be_nil
    end
  end

  describe ".find_by_token" do
    it "returns the confirmation record for a valid token" do
      token = SecureRandom.hex(8)
      EmailConfirmation.create(user_id: user["id"], token: token)

      found = EmailConfirmation.find_by_token(token)
      expect(found).not_to be_nil
      expect(found["token"]).to eq(token)
      expect(found["user_id"].to_i).to eq(user["id"].to_i)
    end

    it "returns nil for invalid token" do
      expect(EmailConfirmation.find_by_token("nonexistent")).to be_nil
    end
  end

  describe ".delete_by_token" do
    it "deletes the confirmation record" do
      token = SecureRandom.hex(8)
      EmailConfirmation.create(user_id: user["id"], token: token)

      EmailConfirmation.delete_by_token(token)
      expect(EmailConfirmation.find_by_token(token)).to be_nil
    end
  end
end
# rubocop:enable Metrics/BlockLength
