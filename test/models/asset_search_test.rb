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

class AssetSearchTest < ActiveSupport::TestCase
  setup do
    @site = create :site
    @asset = create :asset
  end

  test 'empty search should be blank' do
    assert AssetSearch.new.blank?
  end

  test 'should search assets' do
    assert s = AssetSearch.new(query: 'photo')
    assert !s.blank?
    assert r = s.search(@site.assets)
    assert r.where(id: @asset.id).any?

    assert s = AssetSearch.new(query: 'photos')
    assert s.search(@site.assets).where(id:@asset.id).any?

    assert s = AssetSearch.new(query: 'foobar')
    assert !s.blank?
    assert s.search(@site.assets).blank?
  end

end