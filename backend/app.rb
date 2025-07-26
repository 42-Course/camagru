require "sinatra"
require "sinatra/reloader" if development?
require_relative "./app/lib/cors"
require_relative "./app/lib/db"
require_relative "./app/controllers/sessions_controller"

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

  use SessionsController
end

at_exit do
  Database.pool.shutdown do |conn|
    conn.close
    puts "Shutting down DB connections..."
  rescue StandardError
    nil
  end
end
