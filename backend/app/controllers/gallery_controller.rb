require_relative "./base_controller"
require_relative "../models/image"

class GalleryController < BaseController
  DEFAULT_PAGE      = 1
  DEFAULT_PER_PAGE  = 10
  MAX_PER_PAGE      = 100

  api_doc "/gallery", method: :get do
    description(
      "List all public images in the gallery with support for pagination, sorting, and custom per-page limits."
    )
    tags "gallery", "images"
    auth_required value: false

    param :page, Integer, required: false, desc: "Page number (default: 1)"
    param :per_page, Integer, required: false, desc: "Items per page (default: 10, max: 100)"
    param :sort_by, String, required: false, desc: "Sort field: created_at, likes, or comments"
    param :order, String, required: false, desc: "`asc` or `desc` (default: desc)"

    response 200, "Paginated images", example: {
      page: 1,
      per_page: 5,
      total: 32,
      total_pages: 7,
      images: [
        {id: 3, file_path: "/images/abc.png", user_id: 1, created_at: "..."}
      ]
    }
  end

  get "/gallery" do
    page     = (params["page"] || GalleryController::DEFAULT_PAGE).to_i
    per_page = [(params["per_page"] || GalleryController::DEFAULT_PER_PAGE).to_i, GalleryController::MAX_PER_PAGE].min

    sort_by = params["sort_by"]
    order   = params["order"]

    total = Image.gallery_total
    images = Image.gallery_page(page: page, per_page: per_page, sort_by: sort_by, order: order)
    enriched_images = Image.batch_with_metadata(images)

    json_response({
                    page: page,
                    per_page: per_page,
                    total: total,
                    total_pages: (total / per_page.to_f).ceil,
                    images: enriched_images
                  })
  end
end
