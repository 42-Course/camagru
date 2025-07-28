require_relative "./base_model"

class Comment < BaseModel
  def self.find_by_image(image_id)
    query(<<~SQL, [image_id]).to_a
      SELECT comments.*, users.id AS user_id, users.username, users.created_at AS user_created_at
      FROM comments
      JOIN users ON comments.user_id = users.id
      WHERE comments.image_id = $1
      ORDER BY comments.created_at ASC
    SQL
  end

  def self.create(user_id:, image_id:, content:)
    result = query(<<~SQL, [user_id, image_id, content])
      INSERT INTO #{table_name} (user_id, image_id, content, created_at)
      VALUES ($1, $2, $3, NOW())
      RETURNING *
    SQL

    result.ntuples.positive? ? result[0] : nil
  end
end
