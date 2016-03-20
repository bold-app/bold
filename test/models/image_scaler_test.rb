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

class ImageScalerTest < ActiveSupport::TestCase
  setup do
    AssetUploader.enable_processing = true
    Bold::current_site = @site = create :site
    @asset = create :asset
    @scaler = Bold::ImageScaler.new @asset
  end

  teardown do
    AssetUploader.enable_processing = false
  end


  test 'should create scaled image version' do
    cfg = { name: 'small', width: 200, ratio: 2, quality: 50, crop: false }
    assert path = @scaler.create_version(cfg)
    img = MiniMagick::Image.open path
    assert_equal 133, img[:width]
    assert_equal 100, img[:height]
  end

  test 'should create cropped image version' do
    cfg = { name: 'cropped', width: 200, ratio: 2, quality: 50, crop: true }
    assert path = @scaler.create_version(cfg)
    img = MiniMagick::Image.open path
    assert_equal 200, img[:width]
    assert_equal 100, img[:height]
  end

end
