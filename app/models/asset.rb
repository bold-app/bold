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
class Asset < SiteRecord
  include Rails.application.routes.url_helpers

  prepend Taggable

  has_many :fulltext_indices, as: :searchable, dependent: :delete_all
  has_many :request_logs, as: :resource
  belongs_to :creator, class_name: 'User'

  mount_uploader :file, AssetUploader

  validates :file, presence: true
  validates_download_of :file
  validates_integrity_of :file

  after_destroy ->(asset){ asset.remove_file! }

  scope :files, ->{ where "#{table_name}.content_type NOT LIKE 'image/%'" }
  scope :images, ->{ where "#{table_name}.content_type LIKE 'image/%'" }

  acts_as_url :name_for_slug,
    limit: 500,
    truncate_words: true,
    url_attribute: :slug,
    only_when_blank: true,
    sync_url: true,
    scope: :site_id

  %i( title caption width height taken_on attribution original_url
      lat lon gps_altitude ).each do |attribute|
    store_accessor :meta, attribute
  end

  def disk_directory
    if self["disk_directory"].blank?
      site.in_time_zone do
        [
          site_id.to_s,
          created_at.year.to_s,
          created_at.month.to_s,
          created_at.day.to_s,
          id.to_s
        ].join('/').tap do |dir|
          unless frozen?
            self["disk_directory"] = dir
            update_column :disk_directory, dir unless new_record?
          end
        end
      end
    else
      self["disk_directory"]
    end
  end

  def diskfile_path(version_name = nil)
    version = normalize_version version_name
    if version.blank?
      file.url
    else
      ::Bold::ImageVersion.path(file.url, version_name)
    end
  end

  def public_path(version = nil, download = false)
    args = { id: id }
    version = normalize_version version
    args[:version] = version.to_s if version.present?
    download ? download_path(args.merge(filename: filename)) : file_path(args)
  end

  def preview_path(version = 'bold_preview')
    bold_asset_path(self, version: version)
  end


  # Time the picture was taken, according to its meta data.
  #
  # If the meta data value has no time zone info, it is interpreted as being UTC.
  #
  # FEATURE We could however make the picture time zone an attribute and allow it's
  # configuration at upload or any later time and replace UTC with that.
  def taken_on
    # In case taken_on has time zone information, the use_zone call does not
    # matter, it just converts the parse result to UTC.
    @taken_on ||= Time.use_zone('UTC'){ Time.zone.parse meta['taken_on'].to_s } if meta['taken_on']
  rescue
    nil
  end

  def ensure_version!(version = nil)
    if image? && scalable? && version.present? && !readable?(version)
      ScaleImage.call(self)
    end
  end

  def readable?(version = nil)
    File.readable? diskfile_path version
  end

  def jpeg?
    content_type == 'image/jpeg'
  end

  def image?
    !!(content_type.to_s =~ /\Aimage/)
  end

  def scalable?
    !!(content_type.to_s =~ /\Aimage\/(jpeg|png|tiff)\z/)
  end

  def scalable_image?
    image? and scalable?
  end

  def xy_ratio
    width.to_f / height.to_f if image?
  rescue
    nil
  end

  def alt_text
    [title, caption].detect(&:present?)
  end

  def markdown(inline_version = 'IMAGE_VERSION', link_to = 'LINK_TO')
    %{![#{alt_text}](#{slug}!#{inline_version}#{'!'+link_to if link_to.present?}#{" '#{title.gsub "'", "\'"}'" if title.present?})}
  end

  def data_for_index
    {
      a: title,
      b: caption,
      c: tag_list,
      d: file.filename.to_s.split(/\W|_/)
    }
  end

  def to_jq_upload
    {
      "id" => id,
      "markdown" => markdown,
      "name" => read_attribute(:file),
      "size" => file.size,
      "delete_url" => bold_asset_path(self),
      "delete_type" => "DELETE",
    }.tap do |json|
      if image?
        json["thumbnail_url"] = if scalable?
          bold_asset_path self, size: :square_thumb
        else
          bold_asset_path self
        end
      end
    end
  end

  def filename
    p = file&.path
    p.blank? ? 'unknown' : File.basename(p)
  end

  def mime_type
    MIME::Types[content_type][0] rescue nil
  end

  private

  def name_for_slug
    name = filename
    File.basename name, File.extname(name)
  end

  def normalize_version(version)
    version = version.to_s
    version == 'original' ? nil : version
  end

  def set_title
    if title.blank?
      if name = file.filename || read_attribute('file')
        self.title = File.basename name, File.extname(name)
      end
    end
  end

end
