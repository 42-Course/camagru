require "spec_helper"
require_relative "../../app/models/comment"
require_relative "../../app/models/image"
require_relative "../../app/models/user"

# rubocop:disable Metrics/BlockLength
RSpec.describe Comment do
  let(:user) do
    User.create(username: "c_#{SecureRandom.hex(2)}", email: "c@e.com", password: "pass123").tap do |u|
      User.confirm_email!(u["id"])
    end
  end

  let(:image) do
    Image.create(user_id: user["id"], file_path: "/comments/test.png")
  end

  describe ".create" do
    it "adds a new comment to an image" do
      comment = Comment.create(user_id: user["id"], image_id: image["id"], content: "Looks great!")

      expect(comment).to include(
        "user_id" => user["id"],
        "image_id" => image["id"],
        "content" => "Looks great!"
      )
      expect(comment["created_at"]).not_to be_nil
    end
  end

  describe ".find_by_image" do
    it "retrieves comments for an image" do
      Comment.create(user_id: user["id"], image_id: image["id"], content: "1st comment")
      Comment.create(user_id: user["id"], image_id: image["id"], content: "2nd comment")

      comments = Comment.find_by_image(image["id"])

      expect(comments.size).to eq(2)
      expect(comments.map { _1["content"] }).to include("1st comment", "2nd comment")
    end
  end
end
# rubocop:enable Metrics/BlockLength
