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
require 'test_helper'

class ImageScalerJobTest < ActiveJob::TestCase
  setup do
    @site = create :site
  end

  test 'should scale to square thumb' do
    asset = create_asset
    ImageScalerJob.perform_now asset.id

    assert thumb = asset.diskfile_path(:bold_thumb_sq)
    assert File.readable? thumb
    width, height = `identify -format "%wx%h" #{thumb}`.split(/x/).map(&:strip)
    assert_equal width, height
    assert_equal 400, width.to_i
  end

end
