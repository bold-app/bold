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

class Setup::UsersControllerTest < ActionController::TestCase
  setup do
    sign_out :user
    Content.destroy_all
    User.delete_all
    Site.delete_all
    Bold::current_site = nil
    Bold::current_user = nil
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test 'should re-render new when validation failed' do
    post :create, user: { name: 'joe' }
    assert_response :success
  end

  test 'new should redirect if already have one user' do
    create :user
    get :new
    assert_redirected_to new_setup_site_path
  end

  test 'should create user' do
    User.delete_all
    pwd = Faker::Internet.password(8,20)
    assert_difference 'User.count' do
      post :create, user: {
        name: Faker::Name.name, email: Faker::Internet.email,
        password: pwd, password_confirmation: pwd
      }
    end
    assert_redirected_to new_setup_site_path
  end

end