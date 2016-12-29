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

module Bold
  class SitesControllerTest < ActionController::TestCase

    setup do
      @admin = @user
      @user = create :confirmed_user
      @site.add_user! @user
      sign_in @user
    end

    test 'index should redirect user to site if there is only one' do
      get :index
      assert_redirected_to bold_site_path(@site)
    end

    test 'index should show unread items count for sites' do
      another_site = create :site, theme_name: 'test'
      another_site.add_user! @user

      @site.update_attribute :post_comments, 'enabled'
      p = publish_post
      c = create :comment, content: p, author_name: 'Max Muster', body: 'test comment'
      create :unread_item, user: @user, site: @site, item: c
      create :unread_item, user: @admin, site: @site, item: c
      get :index
      assert_response :success
      assert_select 'span.badge', '1'
    end

    test 'user should get index when multiple sites are present' do
      another_site = create :site, theme_name: 'test'
      another_site.add_user! @user
      get :index
      assert_response :success
      assert_select 'td', @site.name
      assert_select 'td', another_site.name
    end

    test 'admin should get index' do
      sign_in @admin
      get :index
      assert_response :success
      assert_select 'td', @site.name
      #assert_select 'a', /new/i
    end

    test 'should get show' do
      get :show, params: { id: @site.id }
      assert_response :success
      assert_select '.navbar', /#{@site.name}/
    end

    test 'should require user' do
      sign_out :user
      get :index
      assert_access_denied
      get :show, params: { id: @site.id }
      assert_access_denied
    end

  end
end

