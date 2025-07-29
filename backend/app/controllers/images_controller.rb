require_relative "./base_controller"
require_relative "../models/image"
require_relative "../models/user"
require_relative "../lib/image_processor"

class ImagesController < BaseController
  api_doc "/images/mine", method: :get do
    description "Retrieve the current user's active (non-archived) images."
    tags "images"
    auth_required value: true

    response 200, "List of active images", example: [
      {
        id: 1,
        file_path: "/images/abc.png",
        user_id: 4,
        deleted_at: "null",
        user: {
          id: 4,
          username: "alice",
          created_at: "2025-07-27T12:00:00Z"
        },
        comments: [],
        likes: []
      }
    ]
  end

  get "/images/mine" do
    images = User.images(current_user["id"])
    enriched_images = Image.batch_with_metadata(images)
    json_response(enriched_images)
  end

  api_doc "/images/archived", method: :get do
    description "Retrieve the current user's archived (soft-deleted) images."
    tags "images"
    auth_required value: true

    response 200, "List of archived images", example: [
      {
        id: 2,
        file_path: "/images/old.png",
        user_id: 4,
        deleted_at: "2024-01-01T10:00:00Z",
        user: {
          id: 4,
          username: "alice",
          created_at: "2025-07-27T12:00:00Z"
        },
        comments: [],
        likes: []
      }
    ]
  end

  get "/images/archived" do
    all_images = User.images_and_archives(current_user["id"])
    archived = all_images.select { _1["deleted_at"] }
    enriched_archived_images = Image.batch_with_metadata(archived)

    json_response(enriched_archived_images)
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

  # rubocop:disable Metrics/BlockLength
  api_doc "/images", method: :post do
    description(
      "Upload a new image with sticker overlays. " \
      "Accepts base64, file upload, remote URL, or local path. " \
      "Composites stickers server-side and returns enriched image metadata."
    )
    tags "images", "stickers"
    auth_required value: true

    param :image, String, required: true,
                          desc: "Base image to be used (can be data URL, remote URL, local path, or uploaded file)"
    param :preview_width, Integer, required: true, desc: "Preview width relative to the x, y and scale"
    param :preview_height, Integer, required: true, desc: "Preview height relative to the x, y and scale"
    param :stickers, Array, required: true,
                            desc: "Array of sticker overlays with position and scale (layered first-to-last)" do
      param :sticker_id, Integer, required: true, desc: "Sticker ID to overlay"
      param :x, Integer, required: true, desc: "X position of the sticker"
      param :y, Integer, required: true, desc: "Y position of the sticker"
      param :scale, Float, required: false, desc: "Optional scale factor (default: 1.0)"
    end

    response 201, "Image created", example: {
      id: 42,
      user_id: 4,
      file_path: "/uploads/user_04/2025/07/28/image_a1b2c3d4.png",
      created_at: "2025-07-28T15:42:00Z",
      deleted_at: nil,
      user: {
        id: 4,
        username: "alice",
        created_at: "2025-07-27T12:00:00Z"
      },
      comments: [],
      likes: []
    }

    response 400, "Invalid or missing input", example: {
      error: "Invalid image data"
    }

    response 401, "Unauthorized", example: {
      error: "Unauthorized"
    }

    response 500, "Server-side failure", example: {
      error: "Failed to save image"
    }
  end

  post "/images" do
    halt 401, json_error("Unauthorized") unless current_user

    # 1. Validate + extract input
    payload = parse_json_body
    raw_image = params["image"] || payload["image"]
    preview_width = payload["preview_width"].to_i || 854
    preview_height = payload["preview_height"].to_i || 540
    stickers = payload["stickers"]

    halt 400, json_error("Invalid image data") unless raw_image
    halt 400, json_error("Invalid sticker data") unless stickers.is_a?(Array)
    halt 400, json_error("At least one sticker must be used") unless stickers.any?

    # 2. Decode base64 or uploaded image
    base_image = ImageProcessor.load_image(raw_image)
    halt 400, json_error("Unsupported image format") unless base_image

    # 3. Fetch sticker file paths from DB
    sticker_ids = stickers.map { _1["sticker_id"] }.uniq
    sticker_map = Sticker.find_by_ids(sticker_ids).index_by { _1["id"] }

    # 4. Apply stickers
    composer = ImageProcessor.new(base_image, preview_width, preview_height)
    stickers.each do |s|
      sticker = sticker_map[s["sticker_id"]]
      halt 400, json_error("Invalid sticker: #{s['sticker_id']}") unless sticker
      composer.add_sticker(
        sticker["file_path"],
        {
          x: s["x"],
          y: s["y"],
          scale: s["scale"] || 1.0,
          rotation: s["rotation"] || 0.0
        }
      )
    end

    # 5. Save to file path (include user ID and date)
    saved_path = composer.save(user_id: current_user["id"])

    # 6. Save to DB
    image_record = Image.create(user_id: current_user["id"], file_path: saved_path)
    halt 500, json_error("Failed to save image") unless image_record

    json_response(Image.with_metadata(image_record))
  end
  # rubocop:enable Metrics/BlockLength
end
