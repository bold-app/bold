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

class UpdateCategoryTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
  end

  test 'should create new permalink when slug changes and redirect old link' do
    c = @site.categories.build name: 'My Category', slug: 'my-cat'
    assert r = CreateCategory.call(c)
    assert r.category_created?
    assert c = r.category
    assert_equal 'my-cat', c.slug
    assert l = c.permalink
    assert_equal 'my-cat', l.path

    assert_difference 'Redirect.count' do
      assert_difference 'Permalink.count' do
        assert UpdateCategory.call(c, slug: 'my-category')
      end
    end

    c.reload
    assert l2 = c.permalink
    assert_equal 'my-category', l2.path

    l.reload
    assert r = l.destination
    assert r.permanent?
    assert_equal '/my-category', r.location
  end

end


