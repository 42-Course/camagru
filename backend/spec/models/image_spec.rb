require "spec_helper"
require_relative "../../app/models/user"
require_relative "../../app/models/image"

# rubocop:disable Metrics/BlockLength

RSpec.describe Image do
  let(:user) do
    User.create(
      username: "img_#{SecureRandom.hex(2)}",
      email: "img_#{SecureRandom.hex(3)}@example.com",
      password: "secure123"
    )
  end

  describe ".create" do
    it "creates an image for a user" do
      image = Image.create(user_id: user["id"], file_path: "/images/photo1.png")

      expect(image).to include(
        "user_id" => user["id"],
        "file_path" => "/images/photo1.png"
      )
      expect(image["id"]).not_to be_nil
    end
  end

  describe ".find_by_id" do
    it "returns the image by ID" do
      image = Image.create(user_id: user["id"], file_path: "/images/photo2.png")
      found = Image.find_by_id(image["id"])

      expect(found).not_to be_nil
      expect(found["file_path"]).to eq("/images/photo2.png")
    end
  end

  describe ".find_by_user" do
    it "returns all images for a user" do
      Image.create(user_id: user["id"], file_path: "/images/photo3.png")
      Image.create(user_id: user["id"], file_path: "/images/photo4.png")

      images = Image.find_by_user(user["id"])

      expect(images).to be_an(Array)
      expect(images.size).to be >= 2
      expect(images.map { _1["file_path"] }).to include("/images/photo3.png", "/images/photo4.png")
    end
  end

  describe ".soft_delete" do
    it "sets deleted_at without removing the record" do
      image = Image.create(user_id: user["id"], file_path: "/images/photo5.png")
      Image.soft_delete(image["id"])

      updated = Image.find_by_id(image["id"])
      expect(updated["deleted_at"]).not_to be_nil
    end
  end

  describe ".delete" do
    it "removes the record from the database" do
      image = Image.create(user_id: user["id"], file_path: "/images/photo6.png")
      Image.delete(image["id"])

      deleted = Image.find_by_id(image["id"])
      expect(deleted).to be_nil
    end
  end

  describe ".gallery_total and .gallery_page" do
    before do
      # Create 6 visible images
      6.times do |i|
        Image.create(user_id: user["id"], file_path: "/images/g#{i}.png")
      end
      # Add 2 archived images (should be excluded)
      archived = Image.create(user_id: user["id"], file_path: "/images/archived1.png")
      Image.soft_delete(archived["id"])
      archived = Image.create(user_id: user["id"], file_path: "/images/archived2.png")
      Image.soft_delete(archived["id"])
    end

    it "returns correct visible total" do
      total = Image.gallery_total
      expect(total).to eq(6)
    end

    it "paginates correctly (per_page = 2, page = 2)" do
      page = Image.gallery_page(page: 2, per_page: 2)
      expect(page.size).to eq(2)
      expect(page[0]["file_path"]).to match(%r{/images/g})
    end

    it "returns images in correct order (default: created_at DESC)" do
      page = Image.gallery_page(page: 1, per_page: 3)
      timestamps = page.map { _1["created_at"] }
      expect(timestamps).to eq(timestamps.sort.reverse)
    end

    it "respects custom sort order (ASC)" do
      asc_page = Image.gallery_page(page: 1, per_page: 3, order: "asc")
      timestamps = asc_page.map { _1["created_at"] }
      expect(timestamps).to eq(timestamps.sort)
    end

    it "ignores archived images" do
      images = Image.gallery_page(page: 1, per_page: 10)
      file_paths = images.map { _1["file_path"] }
      expect(file_paths).not_to include("/images/archived1.png", "/images/archived2.png")
    end
  end
end
# rubocop:enable Metrics/BlockLength
