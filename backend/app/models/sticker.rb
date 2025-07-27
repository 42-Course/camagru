require_relative "./base_model"

class Sticker < BaseModel
  def self.create(name:, file_path:)
    result = query(<<~SQL, [name, file_path])
      INSERT INTO #{table_name} (name, file_path, created_at)
      VALUES ($1, $2, NOW())
      RETURNING *
    SQL

    result.ntuples.positive? ? result[0] : nil
  end
end
