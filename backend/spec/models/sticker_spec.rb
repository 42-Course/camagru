require "spec_helper"
require_relative "../../app/models/sticker"

RSpec.describe Sticker do
  describe ".all" do
    it "returns all stickers" do
      # Insert directly into DB
      Database.with_conn do |conn|
        conn.exec_params(
          "INSERT INTO stickers (name, file_path, created_at) VALUES ($1, $2, NOW()), ($3, $4, NOW())",
          ["Sunglasses", "/stickers/sunglasses.png", "Mustache", "/stickers/mustache.png"]
        )
      end

      stickers = Sticker.all

      expect(stickers).to be_an(Array)
      expect(stickers.size).to be >= 2
      expect(stickers.map { _1["name"] }).to include("Sunglasses", "Mustache")
    end
  end

  describe ".create" do
    it "creates a new sticker" do
      sticker = Sticker.create(name: "Hat", file_path: "/stickers/hat.png")

      expect(sticker).to include(
        "name" => "Hat",
        "file_path" => "/stickers/hat.png"
      )
      expect(sticker["id"]).not_to be_nil
    end
  end
end
