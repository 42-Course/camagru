require_relative "./base_controller"
require_relative "../models/like"
require_relative "../models/image"

class LikesController < BaseController
  api_doc "/images/:id/like", method: :post do
    description "Like a specific image. Only authenticated users may like images."
    tags "likes", "images"
    auth_required value: true

    response 200, "Image liked", example: {
      message: "Image liked"
    }

    response 404, "Image not found", example: {
      error: "Image not found"
    }
  end

  post "/images/:id/like" do
    image = Image.find_by_id(params["id"])
    halt 404, json_error("Image not found") unless image

    Like.create(user_id: current_user["id"], image_id: image["id"])
    json_response({message: "Image liked"})
  end

  api_doc "/images/:id/unlike", method: :delete do
    description "Unlike a previously liked image. Only authenticated users may unlike."
    tags "likes", "images"
    auth_required value: true

    response 200, "Image unliked", example: {
      message: "Image unliked"
    }

    response 404, "Image not found", example: {
      error: "Image not found"
    }
  end

  delete "/images/:id/unlike" do
    image = Image.find_by_id(params["id"])
    halt 404, json_error("Image not found") unless image

    Like.delete(user_id: current_user["id"], image_id: image["id"])
    json_response({message: "Image unliked"})
  end
end
