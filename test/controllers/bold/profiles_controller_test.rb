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
  class ProfilesControllerTest < ActionController::TestCase

    setup do
     # @controller = Admin::ProfilesController.new
    end

    test "should get edit" do
      get :edit
      assert_response :success
      assert_select 'h2', 'Your Profile'
    end

    test 'should update profile' do
      put :update, params: { user: { name: 'John Doe III', time_zone_name: 'Berlin' } }
      assert_redirected_to edit_bold_profile_path
      @user.reload
      assert_equal 'John Doe III', @user.name
      assert_equal 'Berlin', @user.time_zone.name
    end

    test "should get edit password" do
      get :edit_password
      assert_response :success
      assert_select 'h2', 'Change Password'
    end

    test 'should require old password to update password' do
      put :update_password, params: { user: { current_password: 'wrong', password: 'newpassw', password_confirmation: 'newpassw' } }
      assert_response :success
      @user.reload
      assert @user.valid_password?('secret.1')
    end

    test 'should update password' do
      put :update_password, params: { user: { current_password: 'secret.1', password: 'newpassw', password_confirmation: 'newpassw' } }
      assert_redirected_to edit_password_bold_profile_path
      @user.reload
      assert @user.valid_password?('newpassw')
    end

    test "should get edit email" do
      get :edit_email
      assert_response :success
      assert_select 'h2', 'Update Email Address'
    end

    test 'should require password to update email' do
      oldmail = @user.email
      put :update_email, params: { user: { current_password: 'wrong', email: 'newmail@host.com' } }
      assert_response :success
      @user.reload
      assert_nil @user.unconfirmed_email
      assert_equal oldmail, @user.email
    end

    test 'should update email' do
      oldmail = @user.email
      put :update_email, params: { user: { current_password: 'secret.1', email: 'newmail@host.com' } }
      assert_redirected_to edit_email_bold_profile_path
      @user.reload
      assert_equal 'newmail@host.com', @user.unconfirmed_email
      assert_equal oldmail, @user.email
    end

  end
end
