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

class PermalinkResolvingTest < BoldIntegrationTest

  setup do
    @user = create :confirmed_user
    @site = create :site, hostname: 'site1.de', name: 'Site one'
    @post = create :published_post, slug: 'some-post', title: 'hello from site 1', body: 'lorem ipsum', site: @site
    @site.add_user! @user
  end

  test 'should redirect to new slug' do
    assert pl = @post.permalink
    assert old_path = pl.path
    assert_equal '2014/07/some-post', old_path

    assert_difference 'Redirect.count' do
      assert_difference 'Permalink.count' do
        @post.update_attribute :slug, 'new-link'
      end
    end
    @post.reload
    assert pl2 = @post.permalink
    assert new_path = pl2.path
    assert_equal '2014/07/new-link', new_path

    pl.reload
    assert r = pl.destination
    assert_equal Redirect, r.class
    assert_equal '/2014/07/new-link', r.location

    set_host 'site1.de'
    visit '/'+old_path
    assert_equal '/2014/07/new-link', current_path
    assert has_content? 'hello from site 1'
  end

end