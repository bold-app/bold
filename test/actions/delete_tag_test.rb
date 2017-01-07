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

class DeleteTagTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
    @post = publish_post title: 'my post', tag_list: 'foo'
    @tag = Tag.find_by_slug 'foo'
  end

  test 'should delete tag' do
    assert_difference 'Tag.count', -1 do
      assert_difference 'Tagging.count', -1 do
        DeleteTag.call @tag
      end
    end
  end

  test 'should replace tag with other tag' do
    assert @bar = CreateTag.call('bar', site: @site).tag

    assert_difference 'Tag.count', -1 do
      assert_no_difference 'Tagging.count' do
        DeleteTag.call @tag, replace_with: @bar
      end
    end

    assert_equal @post, Post.tagged_with('bar').first
  end

end
