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
end
