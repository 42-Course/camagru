require_relative "./base_model"

class Image < BaseModel
  def self.create(user_id:, file_path:)
    result = query(<<~SQL, [user_id, file_path])
      INSERT INTO #{table_name} (user_id, file_path, created_at)
      VALUES ($1, $2, NOW())
      RETURNING *
    SQL

    result.ntuples.positive? ? result[0] : nil
  end

  def self.find_by_user(user_id, exclude_archived: true)
    condition = exclude_archived ? "AND deleted_at IS NULL" : ""
    query("SELECT * FROM #{table_name} WHERE user_id = $1 #{condition} ORDER BY created_at DESC", [user_id]).to_a
  end

  def self.delete(id)
    query("DELETE FROM #{table_name} WHERE id = $1", [id])
  end

  def self.soft_delete(id)
    query("UPDATE #{table_name} SET deleted_at = NOW() WHERE id = $1", [id])
  end

  def self.find_by_id(id)
    result = query("SELECT * FROM #{table_name} WHERE id = $1 LIMIT 1", [id])
    result.ntuples.positive? ? result[0] : nil
  end
end
