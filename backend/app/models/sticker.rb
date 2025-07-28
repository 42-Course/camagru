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

  def self.find_by_ids(ids)
    return [] if ids.empty?

    placeholders = ids.each_index.map {|i| "$#{i + 1}" }.join(", ")
    result = query("SELECT * FROM #{table_name} WHERE id IN (#{placeholders})", ids)
    result.to_a
  end
end
