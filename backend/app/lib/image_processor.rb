require "mini_magick"
require "fileutils"
require "securerandom"
require "date"
require "net/http"
require "uri"
require "base64"

# rubocop:disable Naming/MethodParameterName, Metrics/AbcSize, Metrics/MethodLength
class ImageProcessor
  def self.load_image(source)
    load_image_from_path(source)
  end

  def initialize(base_image, preview_width, preview_height)
    @image = base_image
    @preview_width = preview_width
    @preview_height = preview_height
    @uses_gif_stickers = false

    format = base_image["%m"].strip.downcase
    @frames = format == "gif" ? base_image.frames : [base_image]
  end

  def add_sticker(sticker_path, options={})
    sticker = self.class.load_image_from_path(sticker_path)
    return unless sticker

    x = options[:x].to_i
    y = options[:y].to_i
    scale = options[:scale].to_f
    rotation = options[:rotation].to_f

    puts "\n=== [Sticker Debug Info] ==="
    puts "Sticker path: #{sticker_path}"
    puts "Original input position: (#{x}, #{y})"
    puts "Options: #{options.inspect}"
    puts "Original sticker size: #{sticker.width}x#{sticker.height}"

    x, y = normalize_position(x, y)
    scale = normalize_scale(scale)
    resize_sticker!(sticker, scale)
    rotate_sticker!(sticker, rotation)

    puts "Scaled position on image: (#{x.round(2)}, #{y.round(2)})"
    puts "Computed scale: #{scale.round(3)}"
    puts "Rotation: #{rotation} degrees"

    final_x = x.to_i
    final_y = y.to_i

    format = sticker["%m"].strip.downcase
    is_gif = format == "gif" && sticker.frames.count > 1
    if is_gif
      @uses_gif_stickers = true
      base_frame = @frames.first || @image
      @frames = Array.new(sticker.frames.count) { base_frame.dup }

      sticker.frames.each_with_index do |frame, i|
        @frames[i] = @frames[i].composite(frame) do |c|
          c.compose "Over"
          c.geometry "+#{final_x}+#{final_y}"
        end
      end
    else
      @frames.map!.with_index do |frame, _i|
        frame.composite(sticker) do |c|
          c.compose "Over"
          c.geometry "+#{final_x}+#{final_y}"
        end
      end
    end
  end

  def save(user_id:)
    today = Date.today
    dir = File.join("public/uploads", "user_%02d" % user_id, *today.strftime("%Y/%m/%d").split("/"))
    FileUtils.mkdir_p(dir)

    extension = @uses_gif_stickers ? "gif" : "png"
    filename = "image_#{SecureRandom.hex(4)}.#{extension}"
    path = File.join(dir, filename)
    rel_path = path.sub("public/", "")

    if @uses_gif_stickers
      MiniMagick.convert do |convert|
        @frames.each {|f| convert << f.path }
        convert.loop(0)
        convert << path
      end
    else
      @frames.first.format("png")
      @frames.first.write(path)
    end

    base_url = ENV["BASE_URL"] || "http://localhost:9292"
    File.join(base_url, "public", rel_path)
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

  def self.load_remote_image(url)
    uri = URI.parse(url)
    ext = File.extname(uri.path)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      resp = http.get(uri.request_uri)
      raise "Failed to fetch image" unless resp.is_a?(Net::HTTPSuccess)

      Tempfile.open(["remote", ext]) do |f|
        f.binmode
        f.write(resp.body)
        f.flush
        MiniMagick::Image.open(f.path)
      end
    end
  end

  def self.load_local_image(path)
    full_path = File.expand_path(File.join("public", path))
    raise "Unsafe local path" unless full_path.start_with?(File.expand_path("public"))

    MiniMagick::Image.open(full_path)
  end

  private

  def normalize_position(x, y)
    preview_w = @preview_width.to_f
    preview_h = @preview_height.to_f
    image_w = @image.width.to_f
    image_h = @image.height.to_f

    raise "Missing preview dimensions" if preview_w <= 0 || preview_h <= 0

    [x * (image_w / preview_w), y * (image_h / preview_h)]
  end

  def normalize_scale(scale)
    preview_w = @preview_width.to_f
    preview_h = @preview_height.to_f
    image_w = @image.width.to_f
    image_h = @image.height.to_f

    raise "Missing preview dimensions for scale" if preview_w <= 0 || preview_h <= 0

    avg_scale = ((image_w / preview_w) + (image_h / preview_h)) / 2.0
    scale.to_f * avg_scale
  end

  def resize_sticker!(sticker, scale)
    return if scale <= 0

    new_w = (sticker.width * scale).to_i
    new_h = (sticker.height * scale).to_i
    sticker.resize "#{new_w}x#{new_h}"
  end

  def rotate_sticker!(sticker, rotation)
    return if rotation.to_f.zero?

    sticker.combine_options do |cmd|
      cmd.background "none"
      cmd.gravity "center"
      cmd.rotate rotation.to_f
    end
  end
end
# rubocop:enable Naming/MethodParameterName, Metrics/AbcSize, Metrics/MethodLength
