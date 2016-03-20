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

class FrontendTest < BoldIntegrationTest

  setup do
    @post = create :published_post, title: 'Test Post Title', body: 'test post body', post_date: Time.local(2015, 02, 05), slug: 'test-post', site: @site
  end

  test 'should render homepage' do
    visit '/'
    assert has_content? @post.title
    visit '/2015/02/test-post'
    assert has_content? @post.title
    assert has_content? @post.body
  end

  test 'should render 404 for non existing path' do
    visit '/foo'
    assert has_content? 'not found'
  end

end



