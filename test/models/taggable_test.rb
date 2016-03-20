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

class TaggableTest < ActiveSupport::TestCase
  setup do
    Bold::current_site = @site = create :site
    @post = create :post, site: @site
  end

  test 'should tag post' do
    assert_difference 'Tag.count', 1 do
      assert_difference 'Tagging.count', 1 do
        assert @post.update_attribute :tag_list, 'foo Bar multi-Word tag'
      end
    end
    @post.reload
    assert_equal 1, @post.taggings.count
    assert_equal 1, @post.tags.count
    assert_equal 'foo Bar multi-Word tag', @post.tag_list
  end

  test 'should not create tagging when tag fails to save' do
    create :category, name: 'foo'
    assert_no_difference 'Tag.count' do
      assert_no_difference 'Tagging.count' do
        assert_raise(ActiveRecord::StatementInvalid){ @post.update_attribute(:tag_list, 'foo, bar') }
      end
    end
  end

end
