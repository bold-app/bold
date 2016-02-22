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
  class SitesControllerTest < ActionController::TestCase

    setup do
      @admin = create :confirmed_admin
      sign_in :user, @admin
    end

    test 'should require login' do
      sign_out :user
      get :index
      assert_redirected_to '/users/sign_in'
    end

    test 'should require admin except for select' do
      user = create(:confirmed_user)
      @site.add_user! user
      assert user.site_user?(@site)

      sign_in :user, user
      get :index
      assert_access_denied

      sign_in :user, user
      get :new
      assert_access_denied

      sign_in :user, user
      post :create, params: { site: {} }
      assert_access_denied

      sign_in :user, user
      delete :destroy, params: { id: @site.id }
      assert_access_denied

      sign_in :user, user
      get :select
      assert_response :success
    end

    test "should get select" do
      get :select
      assert_response :success
      assert sites = assigns(:sites)
      assert_equal @site, sites.first
    end

    test 'should select site' do
      get :select, params: { id: @site.to_param }
      assert_redirected_to '/bold'
    end

    test "should get index" do
      get :index
      assert_response :success
      assert sites = assigns(:sites)
      assert_equal @site, sites.first
    end

    test "should get new" do
      get :new
      assert_response :success
      assert assigns(:site).new_record?
    end

    test "should get edit" do
      get :edit, params: { id: @site.id }
      assert_response :success
      assert_equal @site, assigns(:site)
    end

    test 'should create site' do
      assert_difference 'Site.count' do
        post :create, params: { site: { name: 'new site', hostname: 'newsite.com', alias_string: 'alias1.de, alias3.com', theme_name: 'test' } }
      end
      assert_redirected_to '/admin/sites'
      assert s = Site.where(hostname: 'newsite.com').first
      assert_equal 'new site', s.name
      assert_equal %w(alias1.de alias3.com), s.aliases
    end

  end
end
