require "pg"

TABLES_TO_CLEAN = %w[
  users
  images
  comments
  likes
  password_reset_tokens
  email_confirmations
  stickers
].freeze

module DBHelpers
  def self.clean_db!
    Database.with_conn do |conn|
      conn.exec("TRUNCATE #{TABLES_TO_CLEAN.join(', ')} RESTART IDENTITY CASCADE;")
    end
  end
end
