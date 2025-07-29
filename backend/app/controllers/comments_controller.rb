require_relative "./base_controller"
require_relative "../models/comment"
require_relative "../models/image"
require_relative "../models/user"

class CommentsController < BaseController
  api_doc "/images/:id/comments", method: :post do
    description "Add a comment to a specific image. Authenticated users only."
    tags "comments", "images"
    auth_required value: true

    param :content, String, required: true, desc: "The body of the comment"

    response 201, "Comment created", example: {
      id: 13,
      user_id: 4,
      image_id: 7,
      content: "Amazing overlay!",
      created_at: "2024-07-25T12:00:00Z"
    }

    response 400, "Missing or empty comment", example: {
      error: "Missing or empty comment"
    }

    response 404, "Image not found", example: {
      error: "Image not found"
    }
  end

  post "/images/:id/comments" do
    image = Image.find_by_id(params["id"])
    halt 404, json_error("Image not found") unless image

    data = json_body
    content = data["content"].to_s.strip
    halt 400, json_error("Missing or empty comment") if content.empty?

    comment = Comment.create(user_id: current_user["id"], image_id: image["id"], content: content)

    owner = User.find_by_id(image["user_id"])
    notifications_enabled = owner["notifications_enabled"] == "t"
    if owner && owner["email"] != current_user["email"] && notifications_enabled
      image_url = image["file_path"]
      commenter_username = current_user["username"]
      comment_content = comment["content"]

      EmailSender.send_comment_notification_email(
        to: owner["email"],
        image_url: image_url,
        image_title: "Image ##{image['id']}",
        commenter_username: commenter_username,
        comment_content: comment_content
      )
    end

    json_response(comment, status: 201)
  end
end
