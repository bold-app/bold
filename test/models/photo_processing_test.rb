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

class PhotoProcessingTest < ActiveSupport::TestCase

  setup do
    AssetUploader.enable_processing = true
    @site = create :site
    @photo = create(:asset)
  end

  teardown do
    AssetUploader.enable_processing = false
  end

  test 'should recognize image' do
    assert @photo.image?, @photo.content_type.inspect
  end

  test 'should store photo data' do
    assert_equal '2400', @photo.width
    assert_equal '1800', @photo.height
    assert_equal 1330563, @photo.file_size
    assert_equal 'image/jpeg', @photo.content_type
  end

#  test 'should set location' do
#    assert p = create(:asset)
#    assert point = p.loc_geographic
#    assert point.x > 0
#    assert point.y > 0
#    assert_equal 5, p.exif['gps_altitude'].to_i
#  end

  test 'should set title and caption' do
    assert p = create(:asset_2)
    assert_equal 'The title', p.title
    assert_equal 'This is the Caption', p.caption
  end

  test 'should extract exif and xmp data' do
    assert p = create(:asset)
    assert date = p.taken_on
    assert_equal '2012-12-23', date.to_date.to_s
  end

  test 'should store tags' do
    assert p = create(:asset)
    assert_equal 5, p.tags.size
  end

end
