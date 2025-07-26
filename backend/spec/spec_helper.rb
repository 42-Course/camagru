ENV["RACK_ENV"] ||= "test"

require "rspec"
require "rack/test"
require_relative "../app"
require_relative "support/db_helpers"

RSpec.configure do |config|
  include Rack::Test::Methods

  # Point the app used for `get`, `post`, etc.
  def app
    CamagruApp
  end

  config.before(:each) do
    DBHelpers.clean_db!
  end

  config.after(:each) do
    DBHelpers.clean_db!
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
