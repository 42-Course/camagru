require "spec_helper"
require_relative "../../app/models/like"
require_relative "../../app/models/image"
require_relative "../../app/models/user"

# rubocop:disable Metrics/BlockLength
RSpec.describe Like do
  let(:user) do
    User.create(username: "l_#{SecureRandom.hex(2)}", email: "l@e.com", password: "pass123").tap do |u|
      User.confirm_email!(u["id"])
    end
  end

  let(:image) do
    Image.create(user_id: user["id"], file_path: "/likes/test.png")
  end

  describe ".create" do
    it "adds a like to the image" do
      like = Like.create(user_id: user["id"], image_id: image["id"])

      expect(like).to include(
        "user_id" => user["id"],
        "image_id" => image["id"]
      )
    end
  end

  describe ".find_by_image" do
    it "retrieves likes for an image" do
      Like.create(user_id: user["id"], image_id: image["id"])

      likes = Like.find_by_image(image["id"])
      expect(likes).to be_an(Array)
      expect(likes.map { _1["user_id"].to_i }).to include(user["id"].to_i)
    end
  end

  describe ".delete" do
    it "removes a like from the image" do
      Like.create(user_id: user["id"], image_id: image["id"])

      Like.delete(user_id: user["id"], image_id: image["id"])
      likes = Like.find_by_image(image["id"])

      expect(likes).to be_empty
    end
  end
end
# rubocop:enable Metrics/BlockLength
