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
require 'application_system_test_case'

class ContentDeletionTest < ApplicationSystemTestCase

  setup do
    @post = publish_post slug: 'some-post', title: 'hello from site 1', body: 'lorem ipsum'
  end

  test 'should not navigate to deleted post' do
    path = @post.path
    visit "/#{path}"
    assert_text 'lorem ipsum'

    DeleteContent.call @post

    visit '/'+path
    assert_text 'not found'
  end

  test 'search should not find deleted post' do
    create_special_page :search
    assert search = @site.search_page
    visit '/'+search.permalink.path+'?q=lorem'
    assert_text 'hello from site 1'

    DeleteContent.call @post

    visit '/'+search.permalink.path+'?q=lorem'
    refute_text 'hello from site 1'
  end

end

