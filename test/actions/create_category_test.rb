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

class CreateCategoryTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
  end

  test 'should create permalink' do
    assert r = CreateCategory.call(name: 'Category One')
    assert r.category_created?
    assert c = r.category
    assert l = c.permalink
    assert_equal 'category-one', l.path
    assert_equal 'category-one', c.path
    assert_equal @site, l.site
  end

  test 'should validate uniqueness of name' do
    assert r = CreateCategory.call(name: 'Category One')
    assert r.category_created?

    assert_no_difference 'Category.count' do
      assert_no_difference 'Permalink.count' do
        assert r = CreateCategory.call(name: 'Category One')
        assert !r.category_created?
        refute r.category.persisted?
      end
    end
  end

  test 'should create unique path in case of collision with other models' do
    create :permalink, path: 'foo'

    assert r = CreateCategory.call(name: 'Foo')
    assert r.category_created?
    assert c = r.category
    assert_equal 'foo', c.slug
    assert_equal 'category-foo', c.permalink.path
  end

end

