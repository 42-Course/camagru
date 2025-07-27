require_relative "./base_controller"
require_relative "../models/sticker"

class StickersController < BaseController
  api_doc "/stickers", method: :get do
    description "Get the list of available sticker overlays. Public route used by the editor."
    tags "stickers"
    auth_required value: false

    response 200, "List of stickers", example: [
      {id: 1, name: "Hat", file_path: "/stickers/hat.png"},
      {id: 2, name: "Laser Eyes", file_path: "/stickers/lasereyes.png"}
    ]
  end

  get "/stickers" do
    stickers = Sticker.all
    json_response(stickers)
  end
end
