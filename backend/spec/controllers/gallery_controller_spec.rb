require "spec_helper"
require_relative "../../app/models/user"
require_relative "../../app/models/image"
require_relative "../../app/controllers/gallery_controller"

# rubocop:disable Metrics/BlockLength
RSpec.describe GalleryController do
  let(:user) do
    u = User.create(
      username: "gal_#{SecureRandom.hex(2)}",
      email: "gallery_#{SecureRandom.hex(3)}@example.com",
      password: "securepass123"
    )
    User.confirm_email!(u["id"])
    u
  end

  before do
    # Create 6 visible images
    6.times do |i|
      Image.create(user_id: user["id"], file_path: "/gallery/test#{i}.png")
    end

    # Create 2 archived images
    2.times do |i|
      img = Image.create(user_id: user["id"], file_path: "/gallery/archived#{i}.png")
      Image.soft_delete(img["id"])
    end
  end

  describe "GET /gallery" do
    it "returns paginated visible images with default params" do
      get "/gallery"
      expect(last_response.status).to eq(200)

      json = JSON.parse(last_response.body)
      expect(json).to include("page", "per_page", "total", "total_pages", "images")
      expect(json["images"].size).to eq(6)
    end

    it "respects custom page and per_page" do
      get "/gallery?page=2&per_page=2"
      json = JSON.parse(last_response.body)

      expect(json["page"]).to eq(2)
      expect(json["per_page"]).to eq(2)
      expect(json["images"].size).to eq(2)
    end

    it "returns results in descending order by default" do
      get "/gallery?per_page=3"
      images = JSON.parse(last_response.body)["images"]
      timestamps = images.map {|img| img["created_at"] }
      expect(timestamps).to eq(timestamps.sort.reverse)
    end

    it "supports ascending order" do
      get "/gallery?order=asc&per_page=3"
      images = JSON.parse(last_response.body)["images"]
      timestamps = images.map {|img| img["created_at"] }
      expect(timestamps).to eq(timestamps.sort)
    end

    it "excludes archived images" do
      get "/gallery"
      file_paths = JSON.parse(last_response.body)["images"].map {|img| img["file_path"] }

      expect(file_paths).not_to include("/gallery/archived0.png", "/gallery/archived1.png")
    end
  end
end
# rubocop:enable Metrics/BlockLength
