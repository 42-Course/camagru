# frozen_string_literal: true

require "spec_helper"
require_relative "../../app/models/user"
require_relative "../../app/models/image"
require_relative "../../app/helpers/session_token"
require_relative "../../app/controllers/images_controller"

# rubocop:disable Metrics/BlockLength
RSpec.describe ImagesController do
  let(:user) do
    u = User.create(
      username: "img_user_#{SecureRandom.hex(2)}",
      email: "img_#{SecureRandom.hex(3)}@example.com",
      password: "secure123"
    )
    User.confirm_email!(u["id"])
    u
  end

  let(:headers) do
    {"CONTENT_TYPE" => "application/json", "HTTP_AUTHORIZATION" => "Bearer #{SessionToken.generate(user['id'])}"}
  end

  describe "GET /images/mine" do
    it "returns active (non-archived) images" do
      Image.create(user_id: user["id"], file_path: "/images/one.png")
      img2 = Image.create(user_id: user["id"], file_path: "/images/two.png")
      Image.soft_delete(img2["id"])

      get "/images/mine", nil, headers
      expect(last_response.status).to eq(200)

      json = JSON.parse(last_response.body)
      expect(json).to be_an(Array)
      expect(json.map { _1["file_path"] }).to include("/images/one.png")
      expect(json.map { _1["file_path"] }).not_to include("/images/two.png")
    end
  end

  describe "GET /images/archived" do
    it "returns only archived images" do
      Image.create(user_id: user["id"], file_path: "/images/visible.png")
      archived = Image.create(user_id: user["id"], file_path: "/images/archived.png")
      Image.soft_delete(archived["id"])

      get "/images/archived", nil, headers
      expect(last_response.status).to eq(200)

      json = JSON.parse(last_response.body)
      expect(json).to be_an(Array)
      expect(json.map { _1["file_path"] }).to include("/images/archived.png")
      expect(json.map { _1["file_path"] }).not_to include("/images/visible.png")
    end
  end

  describe "POST /images/:id/archive" do
    it "archives an owned image" do
      image = Image.create(user_id: user["id"], file_path: "/images/temp.png")

      post "/images/#{image['id']}/archive", nil, headers
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)["message"]).to match(/archived/i)

      updated = Image.find_by_id(image["id"])
      expect(updated["deleted_at"]).not_to be_nil
    end

    it "returns 403 if image does not belong to user" do
      other_user = User.create(username: "hacker", email: "h@x.com", password: "evil123")
      img = Image.create(user_id: other_user["id"], file_path: "/images/hack.png")

      post "/images/#{img['id']}/archive", nil, headers
      expect(last_response.status).to eq(403)
    end
  end

  describe "DELETE /images/:id" do
    it "permanently deletes an owned image" do
      img = Image.create(user_id: user["id"], file_path: "/images/bye.png")

      delete "/images/#{img['id']}", nil, headers
      expect(last_response.status).to eq(200)

      expect(Image.find_by_id(img["id"])).to be_nil
    end

    it "returns 404 if image does not exist" do
      delete "/images/999999", nil, headers
      expect(last_response.status).to eq(404)
    end

    it "returns 403 if image is not owned by user" do
      stranger = User.create(username: "anon", email: "anon@example.com", password: "12345678")
      img = Image.create(user_id: stranger["id"], file_path: "/images/notyours.png")

      delete "/images/#{img['id']}", nil, headers
      expect(last_response.status).to eq(403)
    end
  end
end
# rubocop:enable Metrics/BlockLength
