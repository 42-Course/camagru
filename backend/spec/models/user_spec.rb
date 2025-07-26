require "spec_helper"
require_relative "../../app/models/user"

# rubocop:disable Metrics/BlockLength
RSpec.describe User do
  let(:user_data) do
    {
      username: "testuser",
      email: "test@example.com",
      password_hash: "hashedpw123"
    }
  end

  describe ".create" do
    it "creates a user and returns the inserted record" do
      user = User.create(**user_data)

      expect(user).to include(
        "username" => user_data[:username],
        "email" => user_data[:email],
        "password_hash" => user_data[:password_hash]
      )
      expect(user["id"]).not_to be_nil
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
end
# rubocop:enable Metrics/BlockLength
