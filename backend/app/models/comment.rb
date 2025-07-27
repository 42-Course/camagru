require_relative "./base_model"

class Comment < BaseModel
  def self.find_by_image(image_id)
    query("SELECT * FROM #{table_name} WHERE image_id = $1 ORDER BY created_at ASC", [image_id]).to_a
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
