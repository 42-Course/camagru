require "mini_magick"
require "fileutils"
require "securerandom"
require "date"
require "net/http"
require "uri"
require "base64"

# rubocop:disable Naming/MethodParameterName
class ImageProcessor
  def self.load_image(source)
    load_image_from_path(source)
  end

  def initialize(base_image)
    @image = base_image
  end

  def add_sticker(sticker_path, x, y, scale=1.0)
    sticker = self.class.load_image_from_path(sticker_path)
    return unless sticker

    sticker.resize "#{(sticker.width * scale).to_i}x#{(sticker.height * scale).to_i}"

    @image = @image.composite(sticker) do |c|
      c.compose "Over"
      c.geometry "+#{x}+#{y}"
    end
  end

  def save(user_id:)
    today = Date.today
    dir = File.join("public/uploads", "user_%02d" % user_id, *today.strftime("%Y/%m/%d").split("/"))
    FileUtils.mkdir_p(dir)

    filename = "image_#{SecureRandom.hex(4)}.png"
    path = File.join(dir, filename)
    rel_path = path.sub("public", "") # store relative to public/

    @image.format("png")
    @image.write(path)

    rel_path
  end

  def self.load_image_from_path(path)
    if tempfile?(path)
      MiniMagick::Image.open(path.path)
    elsif base64?(path)
      load_base64_image(path)
    elsif url?(path)
      load_remote_image(path)
    elsif local_path?(path)
      load_local_image(path)
    else
      raise "Unsupported image path: #{path.inspect}"
    end
  rescue StandardError => e
    warn "Image load failed: #{e.message}"
    nil
  end

  def self.tempfile?(path)
    path.respond_to?(:path)
  end

  def self.base64?(str)
    str.is_a?(String) && str.start_with?("data:image")
  end

  def self.url?(str)
    str.is_a?(String) && str.match?(%r{\Ahttps?://})
  end

  def self.local_path?(str)
    str.is_a?(String) && str.start_with?("/")
  end

  def self.load_base64_image(data_url)
    data = data_url.sub(%r{^data:image/[a-z]+;base64,}, "")
    Tempfile.open(["upload", ".png"]) do |f|
      f.binmode
      f.write(Base64.decode64(data))
      f.flush
      MiniMagick::Image.open(f.path)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def self.load_remote_image(url)
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |_http|
      resp = httload_remote_imagep.get(uri.request_uri)
      raise "Failed to fetch image" unless resp.is_a?(Net::HTTPSuccess)

      Tempfile.open(["remote", ".png"]) do |f|
        f.binmode
        f.write(resp.body)
        f.flush
        MiniMagick::Image.open(f.path)
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def self.load_local_image(path)
    full_path = File.expand_path(File.join("public", path))
    raise "Unsafe local path" unless full_path.start_with?(File.expand_path("public"))

    MiniMagick::Image.open(full_path)
  end
end
# rubocop:enable Naming/MethodParameterName
