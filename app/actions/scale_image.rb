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

# Scales an image to all required sizes.
class ScaleImage < ApplicationAction

  Result = ImmutableStruct.new(:success?, :versions_created, [:errors])

  def initialize(asset)
    raise ArgumentError, 'no image given' unless asset && asset.image?

    @asset = asset
    @site = asset.site
  end

  # creates all the versions configured for the asset's site. The hard work
  # happens in CreateImageVersion.
  def call
    @path = @asset.file.current_path
    @count = 0
    @errors = []
    config = { ratio: @asset.xy_ratio }

    (Site::DEFAULT_IMAGE_VERSIONS +
       @site.image_versions).uniq.each do |image_version|

      # create adaptive image sizes if enabled:
      if @site.adaptive_images?
        image_version.possible_variations.each do |v|
          create_version config.merge(v.to_hash)
        end
      else
        create_version config.merge(image_version.to_hash)
      end
    end

    Result.new success: @errors.blank?, versions_created: @count
  end

  private

  def create_version(config)
    r = CreateImageVersion.call @path, config
    if r.version_created?
      @count += 1
    else
      @errors << config[:name]
    end
  end

end
