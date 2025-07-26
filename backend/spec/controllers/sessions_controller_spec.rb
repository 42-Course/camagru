require "spec_helper"
require_relative "../../app/controllers/sessions_controller"
require_relative "../../app/models/user"

# rubocop:disable Metrics/BlockLength
RSpec.describe SessionsController do
  let(:email)    { "login@example.com" }
  let(:password) { "password123" }
  let(:username) { "test" }

  before do
    User.create(username: username, email: email, password: password)
  end

  describe "POST /login" do
    it "returns a token when credentials are valid using email" do
      post "/login", {identity: email, password: password}.to_json, {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json["token"]).to be_a(String)
    end

    it "returns a token when credentials are valid using username" do
      post "/login", {identity: username, password: password}.to_json, {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json["token"]).to be_a(String)
    end

    it "returns 401 for invalid password" do
      post "/login", {identity: email, password: "wrong"}.to_json, {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(401)
    end

    it "returns 401 for unknown email" do
      post "/login", {identity: "notfound@example.com", password: "whatever"}.to_json,
           {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(401)
    end

    it "returns 400 for missing fields" do
      post "/login", {}.to_json, {"CONTENT_TYPE" => "application/json"}

      expect(last_response.status).to eq(400)
    end
  end
end
# rubocop:enable Metrics/BlockLength
