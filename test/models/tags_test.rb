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

class TagsTest < ActiveSupport::TestCase
  setup do
    Bold::current_site = @site = create :site
    create :published_post, site: @site, tag_list: 'one, two, three'
    create :published_post, site: @site, title: 'post two', tag_list: 'two, three, bar'
    create :published_post, site: @site, title: 'post three', tag_list: 'one, three, foo'

    # now we have:
    # bar(1), foo(1), one(2), two(2), three(3)

    @tags = Bold::Tags.new @site
  end

  test 'should handle number of tags less than no of groups' do
    assert_equal 5, @site.tags.size
    assert tags = @tags.grouped_tags(groups: 4, limit: 2)
    assert_equal 2, tags.size
    assert_equal %w(three one), tags.flatten.map(&:name)
  end

  test 'should limit number of tags' do
    assert_equal 5, @site.tags.size
    assert tags = @tags.grouped_tags(groups: 2, limit: 4)
    assert_equal 2, tags.size
    assert_equal %w(three one two bar), tags.flatten.map(&:name)
  end

  test 'should create tags array with group id' do
    weighted_tags = @tags.weighted_tags(groups: 2, limit: 4)
    tags = weighted_tags.transpose
    assert_equal %w(three one two bar), tags[0].map(&:name)
    assert_equal [0, 0, 1, 1], tags[1]
  end

  test 'should group tags in 2 groups' do
    assert_equal 5, @site.tags.size
    assert tags = @tags.grouped_tags(groups: 2)
    assert_equal 2, tags.size
    assert_equal 3, tags[0].size
    assert_equal %w(three one two bar foo), tags.flatten.compact.map(&:name)
  end

  test 'should group tags in 3 groups' do
    assert tags = @tags.grouped_tags(groups: 3)
    assert_equal 3, tags.size
    assert_equal %w(three one two bar foo), tags.flatten.compact.map(&:name)
  end

  test 'should group tags in 4 groups' do
    assert tags = @tags.grouped_tags(groups: 4)
    assert_equal 3, tags.size
    assert_equal %w(three one two bar foo), tags.flatten.compact.map(&:name)
  end

  test 'should group tags in 5 groups' do
    assert tags = @tags.grouped_tags(groups: 5)
    assert_equal 5, tags.size
    assert_equal %w(three one two bar foo), tags.flatten.map(&:name)
  end

end
