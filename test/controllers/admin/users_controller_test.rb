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
  class UsersControllerTest < ActionController::TestCase

    setup do
      @admin = create :confirmed_admin
      sign_in :user, @admin
    end

    test 'should require login' do
      sign_out :user
      get :index
      assert_redirected_to '/users/sign_in'
    end

    test 'should require admin' do
      user = create(:confirmed_user)

      sign_in :user, user
      get :index
      assert_access_denied

      sign_in :user, user
      get :edit, id: @admin.id
      assert_access_denied

      sign_in :user, user
      patch :update, id: @admin.id, user: {}
      assert_access_denied

      sign_in :user, user
      delete :destroy, id: @admin.id
      assert_access_denied
    end

    test "should get index" do
      user = create :confirmed_user
      get :index
      assert_response :success
      assert_select 'td', /^#{user.display_name}/
    end

    test "should get locked" do
      user = create :locked_user
      get :locked
      assert_response :success
      assert_select 'td', /^#{user.display_name}/
    end

    test "should get show" do
      user = create :user
      get :show, id: user.id
      assert_response :success
      assert_equal user, assigns(:user)
    end

    test "should get edit" do
      user = create :user
      xhr :get, :edit, id: user.to_param
      assert_response :success
      assert_equal user, assigns(:user)
    end

    test 'should update user' do
      user = create :user
      xhr :put, :update, id: user.to_param, user: { name: 'new name'}
      assert_response :success
      user.reload
      assert_equal 'new name', user.name
    end

    test "should lock user" do
      user = create :confirmed_user
      put :lock, id: user.to_param
      assert_redirected_to admin_user_path(user)
      user.reload
      assert user.access_locked?
    end

    test "should unlock user" do
      user = create :locked_user
      put :unlock, id: user.to_param
      assert_redirected_to admin_user_path(user)
      user.reload
      assert !user.access_locked?
    end

    test 'should reset password' do
      user = create :confirmed_user, password: 'secret123', password_confirmation: 'secret123'
      assert user.valid_password?('secret123')
      assert_enqueued_jobs 1 do
        put :reset_password, id: user.to_param
      end
      assert_redirected_to admin_user_path(user)
      user.reload
      assert !user.valid_password?('secret123')
    end

    test 'should deny actions on current user' do
      put :lock, id: @admin.to_param
      assert_redirected_to admin_user_path(@admin)
      @admin.reload
      assert !@admin.access_locked?

      assert_no_enqueued_jobs do
        put :reset_password, id: @admin.to_param
      end
      assert_redirected_to admin_user_path(@admin)
      @admin.reload
      assert @admin.valid_password?('secret.1')

      delete :destroy, id: @admin.to_param
      assert_redirected_to admin_user_path(@admin)
      assert_equal 1, User.where(id: @admin.id).count
    end
  end
end