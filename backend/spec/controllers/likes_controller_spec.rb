require "spec_helper"
require_relative "../../app/models/user"
require_relative "../../app/models/image"
require_relative "../../app/helpers/session_token"

# rubocop:disable Metrics/BlockLength
RSpec.describe LikesController do
  let(:user) do
    u = User.create(username: "like_user", email: "like@example.com", password: "pass123")
    User.confirm_email!(u["id"])
    u
  end

  let(:headers) do
    {"CONTENT_TYPE" => "application/json", "HTTP_AUTHORIZATION" => "Bearer #{SessionToken.generate(user['id'])}"}
  end

  let(:image) do
    Image.create(user_id: user["id"], file_path: "/likes/test.png")
  end

  describe "POST /images/:id/like" do
    it "likes an image" do
      post "/images/#{image['id']}/like", nil, headers
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to include("message" => "Image liked")
    end

    it "returns 404 for unknown image" do
      post "/images/999999/like", nil, headers
      expect(last_response.status).to eq(404)
    end
  end

  describe "DELETE /images/:id/unlike" do
    it "unlikes an image" do
      # like first
      post "/images/#{image['id']}/like", nil, headers
      delete "/images/#{image['id']}/unlike", nil, headers

      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to include("message" => "Image unliked")
    end

    it "returns 404 if image does not exist" do
      delete "/images/999999/unlike", nil, headers
      expect(last_response.status).to eq(404)
    end
  end
end
# rubocop:enable Metrics/BlockLength
