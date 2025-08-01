require "sinatra"
require "sinatra/reloader" if development?
require_relative "./app/lib/cors"
require_relative "./app/lib/db"
require_relative "./app/controllers/sessions_controller"
require_relative "./app/controllers/users_controller"
require_relative "./app/controllers/password_resets_controller"
require_relative "./app/controllers/stickers_controller"
require_relative "./app/controllers/images_controller"
require_relative "./app/controllers/gallery_controller"
require_relative "./app/controllers/likes_controller"
require_relative "./app/controllers/comments_controller"

# CamagruApp is the main Sinatra application class that handles
# all HTTP routes and configuration for the Camagru backend.
class CamagruApp < Sinatra::Base
  configure :production do
    puts "🛡️ Rack::Protection Middleware disabled"
    use Rack::Protection::HostAuthorization, permitted_hosts: ["camagru42.fly.dev"]
  end

  configure :development do
    puts "♻️  Sinatra::Reloader enabled for development"
    register Sinatra::Reloader
  end

  use CORS

  get "/" do
    {message: "Welcome to CamagruApp"}.to_json
  end

  get "/public/uploads/*" do
    file_path = params["splat"].first
    full_path = File.expand_path("public/uploads/#{file_path}")

    halt 403 unless full_path.start_with?(File.expand_path("public/uploads/"))
    halt 404 unless File.exist?(full_path)

    send_file full_path
  end

  get "/public/stickers/*" do
    file_path = params["splat"].first
    full_path = File.expand_path("public/stickers/#{file_path}")

    halt 403 unless full_path.start_with?(File.expand_path("public/stickers/"))
    halt 404 unless File.exist?(full_path)

    send_file full_path
  end

  use SessionsController
  use UsersController
  use PasswordResetsController
  use StickersController
  use ImagesController
  use GalleryController
  use LikesController
  use CommentsController
end

at_exit do
  Database.pool.shutdown do |conn|
    conn.close
    puts "Shutting down DB connections..."
  rescue StandardError
    nil
  end
end
