require_relative "./base_model"

class User < BaseModel
  def self.find_by_email(email)
    result = query("SELECT * FROM #{table_name} WHERE email = $1 LIMIT 1", [email])
    result.ntuples.positive? ? result[0] : nil
  end

  def self.find_by_username(username)
    result = query("SELECT * FROM #{table_name} WHERE username = $1 LIMIT 1", [username])
    result.ntuples.positive? ? result[0] : nil
  end

  def self.find_public_by_id(id)
    result = query("SELECT id, username, created_at FROM #{table_name} WHERE id = $1 LIMIT 1", [id])
    result.ntuples.positive? ? result[0] : nil
  end

  def self.create(username:, email:, password:)
    password_hash = PasswordHasher.hash_password(password)
    result = query(<<~SQL, [username, email, password_hash])
      INSERT INTO #{table_name} (username, email, password_hash, notifications_enabled, created_at, updated_at)
      VALUES ($1, $2, $3, TRUE, NOW(), NOW())
      RETURNING *
    SQL

    result[0]
  end

  def self.confirm_email!(user_id)
    query("UPDATE #{table_name} SET confirmed_at = NOW(), updated_at = NOW() WHERE id = $1", [user_id])
  end

  def self.update_password!(user_id, raw_password)
    hashed = PasswordHasher.hash_password(raw_password)
    query(
      "UPDATE #{table_name} SET password_hash = $1, updated_at = NOW() WHERE id = $2",
      [hashed, user_id]
    )
  end

  def self.images(user_id)
    Image.find_by_user(user_id, exclude_archived: true)
  end

  def self.images_and_archives(user_id)
    Image.find_by_user(user_id, exclude_archived: false)
  end

  def self.liked_image?(user_id, image_id)
    row = query("SELECT 1 FROM likes WHERE user_id = $1 AND image_id = $2 LIMIT 1", [user_id, image_id]).first
    !row.nil?
  end
end
