require "spec_helper"
require_relative "../../app/models/sticker"

RSpec.describe StickersController do
  before do
    Database.with_conn do |conn|
      conn.exec_params(
        "INSERT INTO stickers (name, file_path, created_at) VALUES ($1, $2, NOW())",
        ["Crown", "/stickers/crown.png"]
      )
    end
  end

  describe "GET /stickers" do
    it "returns a list of stickers" do
      get "/stickers"
      expect(last_response.status).to eq(200)

      json = JSON.parse(last_response.body)
      expect(json).to be_an(Array)
      expect(json.first["name"]).to eq("Crown")
    end
  end
end
