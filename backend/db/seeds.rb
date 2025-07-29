# frozen_string_literal: true

require_relative "../app/models/user"
require_relative "../app/models/image"
require_relative "../app/models/like"
require_relative "../app/models/comment"
require_relative "../app/models/sticker"
require_relative "../app/helpers/password_hasher"

require "faker"
require "securerandom"

puts "🌱 Seeding Camagru database..."

TOTAL_USERS = 10
MAX_IMAGES_PER_USER = 3
MAX_SET = 6
COMMENTS_PER_IMAGE = 2
LIKES_PER_IMAGE = 3

users = []
images = []
likes_count = 0
comments_count = 0
gen_fake_images = false
# ---------------------------
# Stickers
# ---------------------------
puts "✨ Creating stickers..."

base_url = ENV["BASE_URL"] || "http://localhost:9292"
sticker_dir = File.join("public", "stickers")
stickers = []

Dir.glob("#{sticker_dir}/*.{png,gif,jpg,jpeg}").each do |path|
  filename = File.basename(path)
  name = File.basename(filename, ".*").tr("_", " ").capitalize

  url = File.join(base_url, "public", "stickers", filename)

  stickers << Sticker.create(name: name, file_path: url)
  puts "➕ Sticker: #{name}"
end

# ---------------------------
# Users
# ---------------------------
puts "👤 Creating users..."
TOTAL_USERS.times do
  username = Faker::Internet.unique.username(specifier: 5..10)
  email = Faker::Internet.unique.email(name: username)

  user = User.create(
    username: username,
    email: email,
    password: "password123"
  )

  User.confirm_email!(user["id"])
  users << user
  puts "✅ User created: #{username}"
end

if gen_fake_images
  # ---------------------------
  # Images
  # ---------------------------
  puts "🖼️ Creating images for users..."
  users.each do |user|
    rand(1..MAX_IMAGES_PER_USER).times do
      path = "https://picsum.photos/seed/#{SecureRandom.hex(4)}/640/480"
      image = Image.create(user_id: user["id"], file_path: path)
      images << image
      puts "📷 #{user['username']} uploaded #{path}"
    end
  end

  # ---------------------------
  # Comments
  # ---------------------------
  puts "💬 Adding comments..."
  images.each do |image|
    rand(1..COMMENTS_PER_IMAGE).times do
      commenter = users.sample
      content = Faker::Hipster.sentence(word_count: 4)
      Comment.create(user_id: commenter["id"], image_id: image["id"], content: content)
      comments_count += 1
      puts "💬 #{commenter['username']} → image##{image['id']}: #{content}"
    end
  end

  # ---------------------------
  # Likes
  # ---------------------------
  puts "❤️ Adding likes..."
  images.each do |image|
    likers = users.sample(rand(1..LIKES_PER_IMAGE))
    likers.each do |liker|
      Like.create(user_id: liker["id"], image_id: image["id"])
      likes_count += 1
      puts "❤️ #{liker['username']} liked image##{image['id']}"
    end
  end
end

puts "\n✅ Done seeding Camagru!"
puts "👤 Users:     #{users.size}" unless users.empty?
puts "🖼️ Images:    #{images.size}" unless images.empty?
puts "💬 Comments:  #{comments_count}" unless comments_count.zero?
puts "❤️ Likes:     #{likes_count}" unless likes_count.zero?
puts "✨ Stickers:  #{stickers.size}" unless stickers.empty?
