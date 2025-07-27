require_relative "./base_model"

class PasswordResetToken < BaseModel
  def self.create(user_id:, token:, expires_at:)
    query(<<~SQL, [user_id, token, expires_at])
      INSERT INTO #{table_name} (user_id, token, expires_at, created_at)
      VALUES ($1, $2, $3, NOW())
    SQL
  end

  def self.find_valid(token)
    result = query(<<~SQL, [token])
      SELECT * FROM #{table_name}
      WHERE token = $1 AND expires_at > NOW()
      LIMIT 1
    SQL
    result.ntuples.positive? ? result[0] : nil
  end

  def self.delete_by_token(token)
    query("DELETE FROM #{table_name} WHERE token = $1", [token])
  end
end
