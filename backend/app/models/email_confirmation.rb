require_relative "./base_model"

class EmailConfirmation < BaseModel
  def self.create(user_id:, token:)
    result = query(<<~SQL, [user_id, token])
      INSERT INTO #{table_name} (user_id, token, created_at)
      VALUES ($1, $2, NOW())
      RETURNING *
    SQL

    result[0]
  end

  def self.find_by_token(token)
    result = query("SELECT * FROM #{table_name} WHERE token = $1 LIMIT 1", [token])
    result.ntuples.positive? ? result[0] : nil
  end

  def self.delete_by_token(token)
    query("DELETE FROM #{table_name} WHERE token = $1", [token])
  end
end
