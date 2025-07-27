require_relative "../lib/db"

class BaseModel
  def self.table_name
    singular_table_name = underscore(name.split("::").last)
    "#{singular_table_name}s"
  end

  def self.underscore(str)
    str
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr("-", "_")
      .downcase
  end

  def self.all
    query("SELECT * FROM #{table_name}").to_a
  end

  def self.find_by_id(id)
    result = query("SELECT * FROM #{table_name} WHERE id = $1 LIMIT 1", [id])
    result.ntuples.positive? ? result[0] : nil
  end

  def self.query(sql, params=[])
    Database.with_conn do |conn|
      conn.exec_params(sql, params)
    end
  end
end
