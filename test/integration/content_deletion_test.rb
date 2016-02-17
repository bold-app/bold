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

class ContentDeletionTest < BoldIntegrationTest

  setup do
    @post = create :published_post, slug: 'some-post', title: 'hello from site 1', body: 'lorem ipsum', site: @site
  end

  test 'should not navigate to deleted post' do
    path = @post.permalink.path
    visit '/'+path
    assert has_content? 'lorem ipsum'

    assert_no_difference 'Post.count' do
      assert_difference 'Permalink.count', -1 do
        @post.delete
      end
    end

    visit '/'+path
    assert_equal 404, status_code
    assert has_content? 'not found'
  end

  test 'search should not find deleted post' do
    assert search = @site.search_page
    visit '/'+search.permalink.path+'?q=lorem'
    assert has_content? 'hello from site 1'

    assert_no_difference 'Post.count' do
      assert_difference 'Permalink.count', -1 do
        @post.delete
      end
    end

    visit '/'+search.permalink.path+'?q=lorem'
    assert !has_content?('hello from site 1')
  end

end
