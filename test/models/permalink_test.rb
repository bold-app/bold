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
    Bold::current_site = @site = create :site
  end

  test 'should build path' do
    assert_equal 'foo/bar', Permalink.build_path('foo', 'BAR')
    assert_equal 'foo/bar', Permalink.build_path(['foo', 'BAR'])
    assert_equal 'foo/bar', Permalink.build_path('foo/bar')
    assert_equal 'foo/bar', Permalink.build_path(['foo/bar'])
  end

  test 'should validate path uniqueness' do
    create :permalink, path: 'my-category'
    p = Permalink.new path: 'my-category'
    assert !p.valid?
    assert p.errors[:path].any?

    p = Permalink.new path: 'My-category'
    assert !p.valid?
    assert p.errors[:path].any?
  end

  test 'should redirect to new location' do
    l = create :permalink
    assert_difference 'Redirect.count' do
      l.redirect_to '/new-link'
      l.save
    end
    l.reload
    assert r = l.destination
    assert_equal Redirect, r.class
    assert_equal '/new-link', r.location
  end
end
