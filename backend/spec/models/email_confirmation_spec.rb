require "spec_helper"
require_relative "../../app/models/email_confirmation"
require_relative "../../app/models/user"
require_relative "../../app/helpers/password_hasher"

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
end
