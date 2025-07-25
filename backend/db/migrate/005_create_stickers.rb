require_relative "../../app/lib/db"

Database.temp_conn do |conn|
  conn.exec <<~SQL
    CREATE TABLE IF NOT EXISTS stickers (
      id SERIAL PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      file_path TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  SQL
end
