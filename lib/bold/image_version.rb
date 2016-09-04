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
    attr_writer :dpr

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

    VALID_DPR = 1..3
    validates :dpr,
      numericality: { allow_blank: false },
      inclusion: { in: VALID_DPR }


    def valid?
      self.dpr ||= 1
      self.quality ||= 80
      self.crop = false if crop.nil?
      self.gravity = 'Center' if gravity.blank?
      super
    end

    def dpr
      @dpr ||= 1
    end


    # hi res displays still look good with higher compression due to smaller
    # pixel size
    HIRES_JPG_QUALITY = 55

    # Returns an image version derived from this one, suitable for the given
    # display characteristics.
    #
    # If a screen size (in points) is given and this version has been
    # configured with alternative dimensions, the one most suitable for the
    # given size will be used.
    #
    # dpr is the device pixel ratio (2 for retina and similar, 3 on iphone 6+,
    # 1 on standard displays)
    #
    def for_display(dpr: 1, size: nil, mobile: nil, name: nil)

      # find a suitable alternative for the given screen size
      name ||= find_alternative(size, mobile)
      if name
        v = alternative(name)
      else
        v = self.dup
      end
      v.dpr = dpr
      return v
    end

    def dpr=(new_dpr)
      raise ArgumentError, 'can only set dpr on base version!' if dpr > 1
      return if dpr == new_dpr

      @dpr = new_dpr
      self.quality = HIRES_JPG_QUALITY if new_dpr > 1
      self.name = "#{name}_#{new_dpr}x"

      self.width  = (new_dpr * width ).to_i if width
      self.height = (new_dpr * height).to_i if height
    end

    def possible_variations
      VALID_DPR.map do |dpr|
        [ for_display(dpr: dpr) ].tap do |result|
          if @alternatives.present?
            result << @alternatives.map do |alt|
              for_display(dpr: dpr, name: alt[:name])
            end
          end
        end
      end.flatten
    end

    # returns the name of a matching alternative version, if any.
    def find_alternative(size, mobile = false)
      if @alternatives.present?
        if size and alt = @alternatives.detect{|a| max_dimension(a) >= size }
          alt[:name]
        elsif mobile
          # default to smallest version for mobiles
          @alternatives.first[:name]
        end
      end
    end

    def alternatives=(alternatives)
      @alternatives = []
      alternatives.each do |name, params|
        params[:name] = name
        @alternatives << params
      end
      @alternatives.sort!{|a, b| max_dimension(a) <=> max_dimension(b)}
    end

    # returns a version for the named alternative dimensions
    def alternative(name)
      if @alternatives and
        alt = @alternatives.detect{|a| a[:name] == name.to_sym}

        params = to_hash
        params.update alt
        params[:name] = "#{self.name}_#{name}"
        self.class.new params
      end
    end

    def to_hash
      if valid?
        {
          name: name.to_s,
          width: width,
          height: height,
          quality: quality,
          ratio: ratio,
          crop: crop,
          gravity: gravity,
          dpr: dpr
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

    def self.path(base_path, name)
      path = Pathname(base_path)
      path.dirname / "#{name}_#{path.basename}"
    end

    private

    def max_dimension(params)
      [params[:width], params[:height]].compact.max
    end

    def width_required?
      height.blank?
    end

    def height_required?
      width.blank?
    end

  end
end
