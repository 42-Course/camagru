require "sinatra"
require "sinatra/reloader" if development?

# CamagruApp is the main Sinatra application class that handles
# all HTTP routes and configuration for the Camagru backend.
class CamagruApp < Sinatra::Base
  configure :production do
    puts "🛡️ Rack::Protection Middleware disabled"
  end

  configure :development do
    puts "♻️ Sinatra::Reloader enabled for development"
    register Sinatra::Reloader
  end

  get "/" do
    {message: "Welcome to CamagruApp"}.to_json
  end
end

at_exit do
  puts "Shutting down DB connections..."
end
