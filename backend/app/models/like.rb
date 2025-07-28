require_relative "./base_model"

class Like < BaseModel
  def self.find_by_image(image_id)
    query(<<~SQL, [image_id]).to_a
      SELECT likes.*, users.id AS user_id, users.username, users.created_at AS user_created_at
      FROM likes
      JOIN users ON likes.user_id = users.id
      WHERE likes.image_id = $1
    SQL
  end

  def self.create(user_id:, image_id:)
    result = query(<<~SQL, [user_id, image_id])
      INSERT INTO #{table_name} (user_id, image_id, created_at)
      VALUES ($1, $2, NOW())
      RETURNING *
    SQL

    result.ntuples.positive? ? result[0] : nil
  end

  def self.delete(user_id:, image_id:)
    query("DELETE FROM #{table_name} WHERE user_id = $1 AND image_id = $2", [user_id, image_id])
  end
end
