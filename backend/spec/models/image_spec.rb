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
end
# rubocop:enable Metrics/BlockLength
