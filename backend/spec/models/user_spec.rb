require "spec_helper"
require_relative "../../app/models/user"

# rubocop:disable Metrics/BlockLength
RSpec.describe User do
  let(:user_data) do
    {
      username: "testuser",
      email: "test@example.com",
      password: "hashedpw123"
    }
  end

  describe ".create" do
    it "creates a user and returns the inserted record" do
      user = User.create(**user_data)

      expect(user).to include(
        "username" => user_data[:username],
        "email" => user_data[:email]
      )
      expect(user["id"]).not_to be_nil
      expect(user["password_hash"]).not_to be_nil
    end
  end

  describe ".find_by_id" do
    it "finds a user by ID" do
      created = User.create(**user_data)
      found = User.find_by_id(created["id"])

      expect(found).not_to be_nil
      expect(found["email"]).to eq(user_data[:email])
    end
  end

  describe ".find_by_email" do
    it "finds a user by email" do
      User.create(**user_data)
      found = User.find_by_email(user_data[:email])

      expect(found).not_to be_nil
      expect(found["username"]).to eq(user_data[:username])
    end
  end

  describe ".find_by_username" do
    it "finds a user by username" do
      User.create(**user_data)
      found = User.find_by_username(user_data[:username])

      expect(found).not_to be_nil
      expect(found["email"]).to eq(user_data[:email])
    end
  end

  describe ".all" do
    it "returns all users" do
      User.create(**user_data)
      users = User.all

      expect(users).to be_an(Array)
      expect(users.size).to be >= 1
      expect(users.map {|u| u["email"] }).to include(user_data[:email])
    end
  end

  describe ".confirm_email!" do
    it "sets confirmed_at for the given user" do
      user = User.create(**user_data)
      expect(user["confirmed_at"]).to be_nil

      User.confirm_email!(user["id"])
      updated = User.find_by_id(user["id"])

      expect(updated["confirmed_at"]).not_to be_nil
    end
  end

  describe ".update_password!" do
    it "hashes and updates the password" do
      user = User.create(username: "u_#{SecureRandom.hex(2)}", email: "test@u.com", password: "original123")
      new_raw_password = "newsecurepass123"

      User.update_password!(user["id"], new_raw_password)
      updated = User.find_by_id(user["id"])

      expect(PasswordHasher.valid_password?(new_raw_password, updated["password_hash"])).to be true
    end
  end
end
# rubocop:enable Metrics/BlockLength
