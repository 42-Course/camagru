require "spec_helper"
require_relative "../../app/models/user"
require_relative "../../app/models/image"
require_relative "../../app/helpers/session_token"

# rubocop:disable Metrics/BlockLength
RSpec.describe CommentsController do
  let(:user) do
    u = User.create(username: "comment_user", email: "comment@example.com", password: "pass123")
    User.confirm_email!(u["id"])
    u
  end

  let(:headers) do
    {"CONTENT_TYPE" => "application/json", "HTTP_AUTHORIZATION" => "Bearer #{SessionToken.generate(user['id'])}"}
  end

  let(:image) do
    Image.create(user_id: user["id"], file_path: "/comments/test.png")
  end

  describe "POST /images/:id/comments" do
    it "adds a comment to an image" do
      post "/images/#{image['id']}/comments", {content: "Nice work!"}.to_json, headers
      expect(last_response.status).to eq(201)

      json = JSON.parse(last_response.body)
      expect(json["content"]).to eq("Nice work!")
    end

    it "returns 400 for missing content" do
      post "/images/#{image['id']}/comments", {content: " "}.to_json, headers
      expect(last_response.status).to eq(400)
    end

    it "returns 404 if image is not found" do
      post "/images/999999/comments", {content: "test"}.to_json, headers
      expect(last_response.status).to eq(404)
    end
  end
end
# rubocop:enable Metrics/BlockLength
