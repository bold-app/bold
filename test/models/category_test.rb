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

class CategoryTest < ActiveSupport::TestCase
  setup do
    @site = create :site
  end

  test 'should have permalink' do
    assert c = create(:category, name: 'Category One')
    assert_equal 'category-one', c.path
    assert l = c.permalink
    assert_equal 'category-one', l.path
    assert_equal @site, l.site
  end

  test 'should validate uniqueness of permalink' do
    assert create(:category, name: 'Category One')
    c2 = Category.new site: @site, name: 'Category One'
    assert !c2.valid?
    assert c2.errors[:slug].any?
  end

  test 'should validate uniqueness of permalink vs other models' do
    t = create :tag, name: 'Foo'
    assert_equal 'foo', t.path
    c = build :category, name: 'Foo'
    assert !c.save
    assert c.errors[:slug].any?
  end

  test 'should destroy permalink when category is destroyed' do
    c1 = nil
    assert_difference 'Permalink.count' do
      c1 = create(:category, name: 'Category One')
    end
    assert_difference 'Permalink.count', -1 do
      c1.destroy
    end
  end

  test 'should create new permalink when slug changes and redirect old link' do
    assert c = create(:category, name: 'My Category', slug: 'my-cat')
    assert l = c.permalink
    assert_equal 'my-cat', c.path

    assert_difference 'Redirect.count' do
      assert_difference 'Permalink.count' do
        c.update_attributes slug: 'my-category'
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