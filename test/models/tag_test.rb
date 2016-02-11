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

class TagTest < ActiveSupport::TestCase
  setup do
    @site = create :site
  end

  test 'should init slug from name' do
    assert t = create(:tag, name: 'A tag')
    assert_equal 'a-tag', t.slug
  end

  test 'should create permalink' do
    assert t = create(:tag, name: 'A tag')
    assert p = t.permalink
    assert_equal 'a-tag', p.path
  end
end