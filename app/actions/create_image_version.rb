#
# Creates an image version using minimagick
#
# TODO unsharp after resize?
# http://www.imagemagick.org/Usage/resize/#resize_unsharp
# http://redskiesatnight.com/2005/04/06/sharpening-using-image-magick/
class CreateImageVersion < ApplicationAction

  Result = ImmutableStruct.new(:version_created?, :path)

  # path: path to an image
  # config:
  # { name: :large, width: 2048, height: 2048, quality: 70, crop: false }
  #
  # specifying a ratio is also possible, i.e. width: 1000, ratio: 2.7, crop:
  # true.
  # For cropping you may specify gravity as well. Defaults to Center.
  def initialize(path, config)
    @path = Pathname(path)
    @config = config

    @version_name = config[:name]
    if @version_name.blank?
      raise ArgumentError, 'config has to have a :name element'
    end

    @width   = config[:width]
    @height  = config[:height]
    if @width.nil? && @height.nil?
      raise ArgumentError, 'need at least width or height!'
    end

    @gravity = config[:gravity] || 'Center'
    @quality = config[:quality] || 90
    @ratio   = config[:ratio]   || 1

    @crop = !!config[:crop]
  end

  def call
    if @width.blank?
      @width = (@height.to_f * @ratio).to_i
    end
    if @height.blank?
      @height = (@width.to_f / @ratio).to_i
    end

    path = process_with_mini_magick do |img|
      if @crop
        crop img
      else
        resize img
      end
    end

    Result.new version_created: true, path: path
  end

  private

  def resize(img)
    img.combine_options do |cmd|
      cmd.resize "#{@width}x#{@height}>"
      trim_down cmd
    end
  end

  def crop(img)
    cols, rows = img[:dimensions]

    img.combine_options do |cmd|
      if @width != cols || @height != rows
        scale_x = @width/cols.to_f
        scale_y = @height/rows.to_f
        if scale_x >= scale_y
          cols = (scale_x * (cols + 0.5)).round
          rows = (scale_x * (rows + 0.5)).round
          cmd.resize "#{cols}"
        else
          cols = (scale_y * (cols + 0.5)).round
          rows = (scale_y * (rows + 0.5)).round
          cmd.resize "x#{rows}"
        end
      end
      cmd.gravity @gravity
      cmd.background "rgba(255,255,255,0.0)"
      cmd.extent "#{@width}x#{@height}" if cols != @width || rows != @height
      trim_down cmd
    end
  end


  def trim_down(cmd)
    cmd.strip
    cmd.quality @quality
    cmd.depth "8"
    cmd.interlace "plane"
  end


  def process_with_mini_magick
    image = MiniMagick::Image.open(@path)
    yield image
    ::Bold::ImageVersion.path(@path, @version_name).tap do |destination_path|
      image.write destination_path
    end
  end
end
