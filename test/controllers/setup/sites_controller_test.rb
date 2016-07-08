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

class Setup::SitesControllerTest < ActionController::TestCase

  setup do
    sign_out @user if @user
    Site.delete_all
    Bold::current_site = nil
    Bold::current_user = nil
    @user = create :confirmed_admin
  end

  test "should get new" do
    sign_in @user
    get :new
    assert_response :success
  end

  test 'should require login' do
    get :new
    assert_access_denied
    post :create
    assert_access_denied
  end

  test 'should require admin' do
    sign_in create(:confirmed_user)
    get :new
    assert_access_denied
    post :create
    assert_access_denied
  end

  test 'should create site' do
    sign_in @user
    assert_difference 'Site.count' do
      post :create, params: { site: { name: 'foo', theme_name: 'test', hostname: 'example.com' } }
    end
    assert site = Site.where(hostname: 'example.com').first
    assert_redirected_to "/bold/sites/#{site.id}"
  end

  test 'should not run when site exists' do
    sign_in @user
    create :site
    get :new
    assert_redirected_to '/bold/sites'
    post :create
    assert_redirected_to '/bold/sites'
  end

end
