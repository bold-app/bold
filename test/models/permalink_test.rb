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

class PermalinkTest < ActiveSupport::TestCase
  setup do
    @site = create :site
  end

  test 'should allow slashes in path components' do
    c = create :category, name: 'my category', slug: 'my/category'
    assert l = c.permalink
    assert_equal 'my/category', l.path
  end

  test 'should validate path uniqueness' do
    create :category, name: 'my category'
    p = Permalink.new path: 'my-category'
    assert !p.valid?
    assert p.errors[:path].any?

    p = Permalink.new path: 'My-category'
    assert !p.valid?
    assert p.errors[:path].any?
  end

  test 'should redirect to new location' do
    post = create :published_post, slug: 'some-post', title: 'hello from site 1', body: 'lorem ipsum', site: @site
    assert pl = post.permalink
    assert_difference 'Redirect.count' do
      pl.redirect_to '/new-link'
      pl.save
    end
    pl.reload
    assert r = pl.destination
    assert_equal Redirect, r.class
    assert_equal '/new-link', r.location
  end
end