#
# Bold - more than just blogging.
# Copyright (C) 2015-2016 Jens Krämer <jk@jkraemer.net>
#
# This file is part of Bold.
#
# Bold is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Bold is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Bold.  If not, see <http://www.gnu.org/licenses/>.
#
module Bold

  # TODO unsharp after resize?
  # http://www.imagemagick.org/Usage/resize/#resize_unsharp
  # http://redskiesatnight.com/2005/04/06/sharpening-using-image-magick/
  class ImageScaler

    attr_reader :asset

    def initialize(asset)
      raise ArgumentError.new('no image given') unless asset && asset.image?
      @asset = asset
    end


    # creates all the versions configured for the asset's site
    def run
      (Site::DEFAULT_IMAGE_VERSIONS + @asset.site.image_versions).each do |image_version|
        Rails.logger.info "creating version of #{@asset.title} #{image_version.name}"
        create_version image_version.to_hash
      end
    end



    # config: { name: :large, width: 2048, height: 2048, quality: 70, crop: false }
    # specifying a ratio is also possible, i.e. width: 1000, ratio: 2.7, crop: true.
    # For cropping you may specify gravity as well. Defaults to Center.
    def create_version(config = {})
      version_name = config[:name]
      gravity = config[:gravity] || 'Center'
      width = config[:width]
      height = config[:height]
      raise ArgumentError.new('need at least width or height!') if width.blank? && height.blank?
      quality = config[:quality] || 90
      crop = !!config[:crop]

      ratio = config[:ratio] || asset.xy_ratio
      raise ArgumentError.new('could not determine ratio!') if ratio.nil?

      if width.blank?
        width = (height.to_f * ratio).to_i
      end
      if height.blank?
        height = (width.to_f / ratio).to_i
      end

      process_with_mini_magick(asset.file.current_path, version_name) do |img|
        if crop
          cols, rows = img[:dimensions]
          img.combine_options do |cmd|
            if width != cols || height != rows
              scale_x = width/cols.to_f
              scale_y = height/rows.to_f
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
            cmd.gravity gravity
            cmd.background "rgba(255,255,255,0.0)"
            cmd.extent "#{width}x#{height}" if cols != width || rows != height
            trim_down cmd, quality
          end
        else
          img.combine_options do |cmd|
            cmd.resize "#{width}x#{height}>"
            trim_down cmd, quality
          end
        end
      end
    end

    def trim_down(cmd, quality)
      cmd.strip
      cmd.quality quality
      cmd.depth "8"
      cmd.interlace "plane"
    end

    def self.version_path(original, version_name)
      File.join File.dirname(original), "#{version_name}_#{File.basename(original)}"
    end

    def process_with_mini_magick(source_file, version_name)
      self.class.version_path(source_file, version_name).tap do |target_file|
        image = MiniMagick::Image.open(source_file)
        yield image
        image.write target_file
      end
    end
  end
end