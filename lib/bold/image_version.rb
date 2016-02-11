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

  # ImageVersions have the following attributes:
  #
  # { name: :large, width: 2048, height: 2048, quality: 70, crop: false }
  #
  # specifying a ratio is also possible, i.e.
  # { width: 1000, ratio: 2.7, crop: true }
  #
  # For cropping you may specify gravity as well. Defaults to Center.
  #
  class ImageVersion
    include ActiveModel::Model

    attr_accessor :name, :width, :height, :quality, :ratio, :crop, :gravity

    validates :name, presence: true

    validates :width, presence: true, if: :width_required?
    validates :width,
      numericality: { allow_blank: true, only_integer: true, greather_than: 0 }

    validates :height, presence: true, if: :height_required?
    validates :height,
      numericality: { allow_blank: true, only_integer: true, greather_than: 0 }

    validates :quality,
      numericality: { only_integer: true, greather_than: 0 }

    validates :ratio,
      numericality: { allow_blank: true, greather_than: 0 }


    def valid?
      self.quality ||= 70
      self.crop = false if crop.nil?
      self.gravity = 'Center' if gravity.blank?
      super
    end

    def to_hash
      if valid?
        {
          name: name,
          width: width,
          height: height,
          quality: quality,
          ratio: ratio,
          crop: crop,
          gravity: gravity
        }
      else
        raise "invalid imageversion: #{inspect}"
      end
    end

    def pretty_name
      @pretty_name ||= begin
        ::Bold::I18n.t "image_versions.#{name}", raise: true
      rescue ::I18n::MissingTranslationData
        name.to_s.humanize
      end
    end

    private

    def width_required?
      height.blank?
    end

    def height_required?
      width.blank?
    end

  end
end