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

class ImageVersionTest < ActiveSupport::TestCase

  test 'should validate' do
    [
      { name: :small, width: 280, height: 210, quality: 80, crop: true },
      { name: 'big', width: 1000, quality: 80, crop: false, alternatives: { mobile: { width: 700 } } },
    ].each do |params|
      v = Bold::ImageVersion.new params
      assert v.valid?, v.errors.inspect
      assert_equal 1, v.dpr
    end
  end

  test 'should create high res version' do
    v = Bold::ImageVersion.new name: :small, width: 280,
                               height: 210, quality: 80, crop: true
    assert highres = v.for_display(dpr: 2)
    assert highres.valid?
    assert_equal 'small_2x', highres.name
    assert_equal 560, highres.width
    assert_equal 420, highres.height
    assert_equal Bold::ImageVersion::HIRES_JPG_QUALITY, highres.quality
    assert_equal true, highres.crop
    assert_equal 2, highres.dpr
  end

  test 'should build alternative version by name' do
    v = Bold::ImageVersion.new name: 'large', width: 1500,
                               quality: 80,
                               alternatives: {
                                 mobile: { width: 750 },
                                 ipad: { width: 1024 }
                               }
    assert_nil v.alternative('foo')
    assert alt = v.alternative(:mobile)
    assert alt = v.alternative('mobile')
    assert_equal 750, alt.width
    assert_equal 'large_mobile', alt.name
    assert_equal 80, alt.quality
  end

  test 'setting dpr should adjust quality, name and dimensions' do
    v = Bold::ImageVersion.new name: 'large', width: 1500,
                               quality: 80,
                               alternatives: {
                                 mobile: { width: 750 },
                                 ipad: { width: 1024 }
                               }
    v.dpr = 2
    assert_equal 2, v.dpr
    assert_equal 'large_2x', v.name
    assert_equal Bold::ImageVersion::HIRES_JPG_QUALITY, v.quality
    assert_equal 3000, v.width
    assert_equal nil, v.height
  end

  test 'should find alternative version name for size' do
    v = Bold::ImageVersion.new name: 'large', width: 1500,
                               quality: 80,
                               alternatives: {
                                 mobile: { width: 750 },
                                 ipad: { width: 1024 }
                               }
    assert_nil v.find_alternative(nil, false)

    assert_equal :mobile, v.find_alternative(nil, true)
    assert_equal :mobile, v.find_alternative(480)
    assert_equal :mobile, v.find_alternative(750)

    assert_equal :ipad, v.find_alternative(751)
    assert_equal :ipad, v.find_alternative(1024)

    assert_nil v.find_alternative(1025)
  end

  test 'should create high res mobile version' do
    v = Bold::ImageVersion.new name: 'large', width: 1500,
                               quality: 80, alternatives: { mobile: { width: 750 } }
    assert highres = v.for_display(dpr: 2, size: 736)
    assert highres.valid?
    assert_equal 'large_mobile_2x', highres.name
    assert_equal 1500, highres.width
    assert_nil highres.height
    assert_equal Bold::ImageVersion::HIRES_JPG_QUALITY, highres.quality
    assert_equal false, highres.crop
    assert_equal 2, highres.dpr

    assert highres = v.for_display(dpr: 2, mobile: true)
    assert highres.valid?
    assert_equal 'large_mobile_2x', highres.name
    assert_equal 1500, highres.width
    assert_nil highres.height
    assert_equal Bold::ImageVersion::HIRES_JPG_QUALITY, highres.quality
    assert_equal false, highres.crop
    assert_equal 2, highres.dpr
  end

  test 'should create lo res mobile version' do
    v = Bold::ImageVersion.new name: 'large', width: 1500,
                               quality: 80, alternatives: { mobile: { width: 750 } }
    assert new_v = v.for_display(dpr: 1, size: 750)
    assert new_v.valid?
    assert_equal 'large_mobile', new_v.name
    assert_equal 750, new_v.width
    assert_nil new_v.height
    assert_equal 80, new_v.quality
    assert_equal false, new_v.crop
    assert_equal 1, new_v.dpr

    assert new_v = v.for_display(dpr: 1, mobile: true)
    assert new_v.valid?
    assert_equal 'large_mobile', new_v.name
    assert_equal 750, new_v.width
    assert_nil new_v.height
    assert_equal 80, new_v.quality
    assert_equal false, new_v.crop
    assert_equal 1, new_v.dpr
  end

  test 'should give all possible variations' do
    v = Bold::ImageVersion.new name: 'large', width: 1500,
                               quality: 80, alternatives: { mobile: { width: 750 } }
    assert variations = v.possible_variations
    assert_equal 6, variations.size
    assert variations.any?{|v|v.name == 'large'}
    assert variations.any?{|v|v.name == 'large_mobile'}
    assert variations.any?{|v|v.name == 'large_2x'}
    assert variations.any?{|v|v.name == 'large_mobile_2x'}
    assert variations.any?{|v|v.name == 'large_3x'}
    assert variations.any?{|v|v.name == 'large_mobile_3x'}
  end
end
