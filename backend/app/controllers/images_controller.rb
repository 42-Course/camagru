require_relative "./base_controller"
require_relative "../models/image"
require_relative "../models/user"

class ImagesController < BaseController
  api_doc "/images/mine", method: :get do
    description "Retrieve the current user's active (non-archived) images."
    tags "images"
    auth_required value: true

    response 200, "List of active images", example: [
      {id: 1, file_path: "/images/abc.png", user_id: 4, deleted_at: nil}
    ]
  end

  get "/images/mine" do
    images = User.images(current_user["id"])
    json_response(images)
  end

  api_doc "/images/archived", method: :get do
    description "Retrieve the current user's archived (soft-deleted) images."
    tags "images"
    auth_required value: true

    response 200, "List of archived images", example: [
      {id: 2, file_path: "/images/old.png", user_id: 4, deleted_at: "2024-01-01T10:00:00Z"}
    ]
  end

  get "/images/archived" do
    all_images = User.images_and_archives(current_user["id"])
    archived = all_images.select { _1["deleted_at"] }
    json_response(archived)
  end

  api_doc "/images/:id/archive", method: :post do
    description "Soft-delete (archive) an image owned by the current user."
    tags "images"
    auth_required value: true

    response 200, "Image archived", example: {
      message: "Image archived successfully"
    }

    response 403, "Unauthorized (not owner)", example: {
      error: "Unauthorized"
    }

    response 404, "Image not found", example: {
      error: "Image not found"
    }
  end

  post "/images/:id/archive" do
    image = Image.find_by_id(params["id"])
    halt 404, json_error("Image not found") unless image
    halt 403, json_error("Unauthorized") unless image["user_id"].to_i == current_user["id"].to_i

    Image.soft_delete(image["id"])
    json_response({message: "Image archived successfully"})
  end

  api_doc "/images/:id", method: :delete do
    description "Permanently delete an image owned by the current user."
    tags "images"
    auth_required value: true

    response 200, "Image deleted", example: {
      message: "Image deleted successfully"
    }

    response 403, "Unauthorized (not owner)", example: {
      error: "Unauthorized"
    }

    response 404, "Image not found", example: {
      error: "Image not found"
    }
  end

  delete "/images/:id" do
    image = Image.find_by_id(params["id"])
    halt 404, json_error("Image not found") unless image
    halt 403, json_error("Unauthorized") unless image["user_id"].to_i == current_user["id"].to_i

    Image.delete(image["id"])
    json_response({message: "Image deleted successfully"})
  end
end
