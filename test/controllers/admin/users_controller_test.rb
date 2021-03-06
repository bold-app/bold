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
      sign_in @admin
    end

    test 'should require login' do
      sign_out :user
      get :index
      assert_redirected_to '/users/sign_in'
    end

    test 'should require admin' do
      user = create(:confirmed_user)

      sign_in user
      get :index
      assert_access_denied

      sign_in user
      get :edit, params: { id: @admin.id }
      assert_access_denied

      sign_in user
      patch :update, params: { id: @admin.id, user: {} }
      assert_access_denied

      sign_in user
      delete :destroy, params: { id: @admin.id }
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
      get :show, params: { id: user.id }
      assert_response :success
      assert_equal user, assigns(:user)
    end

    test "should get edit" do
      user = create :user
      get :edit, xhr: true, params: { id: user.to_param }
      assert_response :success
      assert_equal user, assigns(:user)
    end

    test 'should update user' do
      user = create :user
      put :update, xhr: true, params: { id: user.to_param, user: { name: 'new name'} }
      assert_response :success
      user.reload
      assert_equal 'new name', user.name
    end

    test "should lock user" do
      user = create :confirmed_user
      put :lock, params: { id: user.to_param }
      assert_redirected_to admin_user_path(user)
      user.reload
      assert user.access_locked?
    end

    test "should unlock user" do
      user = create :locked_user
      put :unlock, params: { id: user.to_param }
      assert_redirected_to admin_user_path(user)
      user.reload
      assert !user.access_locked?
    end

    test 'should reset password' do
      user = create :confirmed_user, password: 'secret123', password_confirmation: 'secret123'
      assert user.valid_password?('secret123')
      assert_enqueued_jobs 1 do
        put :reset_password, params: { id: user.to_param }
      end
      assert_redirected_to admin_user_path(user)
      user.reload
      assert !user.valid_password?('secret123')
    end

    test 'should deny actions on current user' do
      put :lock, params: { id: @admin.to_param }
      assert_redirected_to admin_user_path(@admin)
      @admin.reload
      assert !@admin.access_locked?

      assert_no_enqueued_jobs do
        put :reset_password, params: { id: @admin.to_param }
      end
      assert_redirected_to admin_user_path(@admin)
      @admin.reload
      assert @admin.valid_password?('secret.1')

      delete :destroy, params: { id: @admin.to_param }
      assert_redirected_to admin_user_path(@admin)
      assert_equal 1, User.where(id: @admin.id).count
    end
  end
end
