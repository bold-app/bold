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
    @site = create :site
    create :published_post, site: @site, tag_list: 'one, two, three'
    create :published_post, site: @site, title: 'post two', tag_list: 'two, three, bar'
    create :published_post, site: @site, title: 'post three', tag_list: 'one, three, foo'

    # now we have:
    # bar(1), foo(1), one(2), two(2), three(3)

    @tags = Bold::Tags.new @site
  end

  test 'should group tags in 2 groups' do
    assert_equal 5, @site.tags.size
    assert tags = @tags.grouped_tags(2)
    assert_equal 5, tags.size
    tags = tags.transpose
    assert_equal %w(bar foo one two three), tags[0].map(&:name)
    assert_equal [1,1,2,2,2], tags[1]
  end

  test 'should group tags in 3 groups' do
    assert tags = @tags.grouped_tags(3)
    assert_equal 5, tags.size
    tags = tags.transpose
    assert_equal %w(bar foo one two three), tags[0].map(&:name)
    assert_equal [1,2,2,3,3], tags[1]
  end

  test 'should group tags in 4 groups' do
    assert tags = @tags.grouped_tags(4)
    assert_equal 5, tags.size
    tags = tags.transpose
    assert_equal %w(bar foo one two three), tags[0].map(&:name)
    assert_equal [1,2,3,4,4], tags[1]
  end

  test 'should group tags in 5 groups' do
    assert tags = @tags.grouped_tags(5)
    assert_equal 5, tags.size
    tags = tags.transpose
    assert_equal %w(bar foo one two three), tags[0].map(&:name)
    assert_equal [1,2,3,4,5], tags[1]
  end

end