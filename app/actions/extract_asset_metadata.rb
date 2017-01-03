# Extracts asset meta data from the underlying file and sets it on asset.
#
# Does *not* attempt to save the asset.
class ExtractAssetMetadata < ApplicationAction

  def initialize(asset)
    @asset = asset
    @file = File.new(asset.diskfile_path)
  end

  def call
    @asset.content_type = magic_content_type
    @asset.file_size    = @file.size

    if @asset.file_size > 0 and @asset.image?

      if @asset.jpeg?
        set_jpeg_metadata
      end

      if @asset.width.blank? || @asset.height.blank?
        set_dimensions
      end

    end
  end


  private

  def magic_content_type
    MimeMagic.by_magic(@file).to_s.presence || 'application/octet-stream'
  end

  def set_jpeg_metadata

    # exif
    exifr = EXIFR::JPEG.new @file.path
    @asset.width = exifr.width
    @asset.height = exifr.height
    @asset.taken_on = exifr.date_time_original

    if exifr.gps.present?
      if exifr.gps.longitude.present? && exifr.gps.latitude.present?
        @asset.lon = exifr.gps.longitude
        @asset.lat = exifr.gps.latitude
      end
      if exifr.gps.altitude.present?
        @asset.gps_altitude = exifr.gps.altitude
      end
    end

    # xmp
    if xmp = XMP.parse(exifr)
      if xmp.namespaces.include?('dc')
        @asset.tag_list = xmp.dc.subject rescue []
        if @asset.title.blank?
          @asset.title = xmp.dc.title.first rescue nil
        end
        @asset.caption = xmp.dc.description.join("\n") rescue nil
      end
    end
  end

  def set_dimensions
    @asset.width, @asset.height =
      `identify -format "%wx%h" #{@file.path}`.split(/x/).map(&:to_i)
  end

end
