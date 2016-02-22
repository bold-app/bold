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

module Admin
  class SiteUsersControllerTest < ActionController::TestCase

    setup do
      @admin = create :confirmed_admin
      sign_in :user, @admin
      @user = create(:confirmed_user)
      @site_user = @user.site_users.first
    end

    test 'should get new' do
      get :new, xhr: true, params: { user_id: @user.id }
      assert_response :success
    end

    test 'should get edit' do
      get :edit, xhr: true, params: { user_id: @user.id, id: @site_user.id }
      assert_response :success
    end

    test 'should create site_user' do
      other_site = create :site
      assert_difference 'SiteUser.count' do
        post :create, xhr: true, params: { user_id: @user.id, site_user: { site_id: other_site.id, manager: false }}, session: { current_site_id: @site.id }
      end
      @user.reload
      assert @user.site_user?(other_site)
    end

    test 'should update site_user' do
      assert !@user.site_admin?(@site_user.site)
      patch :update, xhr: true, params: { user_id: @user.id, id: @site_user.id, site_user: { manager: true } }
      @user.reload
      assert @user.site_admin?(@site_user.site)
    end

    test 'should require login' do
      sign_out :user
      get :new, xhr: true, params: {  user_id: @user.id }
      assert_response 401
    end

    test 'should require admin' do
      user = create(:confirmed_user)

      sign_in :user, user
      get :new, xhr: true, params: { user_id: @user.id }
      assert_access_denied

      sign_in :user, user
      post :create, xhr: true, params: { user_id: @user.id, site_user: {} }
      assert_access_denied

      sign_in :user, user
      get :edit, xhr: true, params: { user_id: @user.id, id: @site_user.id }
      assert_access_denied

      sign_in :user, user
      patch :update, xhr: true, params: { user_id: @user.id, id: @site_user.id, site_user: {} }
      assert_access_denied

      sign_in :user, user
      delete :destroy, params: { user_id: @user.id, id: @site_user.id }
      assert_access_denied
    end

  end
end
