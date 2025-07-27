require_relative "./base_model"
require_relative "./image"
require_relative "./comment"

class Image < BaseModel
  DEFAULT_SORT_BY   = "created_at".freeze
  DEFAULT_ORDER     = "DESC".freeze
  ALLOWED_SORTS     = %w[created_at].freeze
  ALLOWED_ORDERS    = %w[asc desc].freeze

  def self.gallery_total
    query("SELECT COUNT(*) FROM #{table_name} WHERE deleted_at IS NULL").first["count"].to_i
  end

  def self.gallery_page(page:, per_page:, sort_by: nil, order: nil)
    sort_column = ALLOWED_SORTS.include?(sort_by) ? sort_by : DEFAULT_SORT_BY
    sort_order  = ALLOWED_ORDERS.include?(order&.downcase) ? order.upcase : DEFAULT_ORDER

    offset = (page - 1) * per_page

    query(<<~SQL, [per_page, offset]).to_a
      SELECT * FROM #{table_name}
      WHERE deleted_at IS NULL
      ORDER BY #{sort_column} #{sort_order}
      LIMIT $1 OFFSET $2
    SQL
  end

  def self.comments(image_id)
    Comment.find_by_image(image_id)
  end

  def self.likes(image_id)
    Like.find_by_image(image_id)
  end

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
