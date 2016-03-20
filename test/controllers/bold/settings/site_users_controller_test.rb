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
  module Settings
    class SiteUsersControllerTest < ActionController::TestCase

      setup do
        @controller = SiteUsersController.new
      end

      test "should get index" do
        get :index, params: { site_id: @site }
        assert_response :success
        assert assigns(:active_users).any?
        assert_select '.left-col a.active', 'Users'
        assert_select '.right-col h2', 'Users'
        assert_select '.right-col h3', 'Active'
      end

      test "should render invite form" do
        get :new, params: { site_id: @site }
        assert_response :success
        assert_select 'h2', /Invite a new user/
        assert_select 'label', /Email/
        assert_select 'label', /Role/
      end

      test "should invite user" do
        assert_difference 'SiteUser.count' do
          assert_difference 'User.count' do
            post :create, params: { site_id: @site, invitation: { email: 'user23@host.com', role: 'editor' } }
          end
        end

        assert_redirected_to bold_site_settings_site_users_path(@site)

        assert u = User.find_by_email('user23@host.com')
        assert_equal @user, u.invited_by
        assert !u.confirmed?
        assert su = u.site_users.first
        assert_equal @site, su.site
        assert !su.manager?
      end

      test 'should resend invitation' do
        i = Invitation.new email: 'resend.please@host.com', role: 'editor', site_id: @site.id
        assert i.create, i.errors.inspect
        assert u = User.find_by_email('resend.please@host.com')

        assert_enqueued_jobs 1 do
          put :resend_invitation, params: { site_id: @site, id: u.id }
        end

        assert_redirected_to bold_site_settings_site_users_path(@site)
      end

      test 'should revoke invitation' do
        i = Invitation.new email: 'revoke.me@host.com', role: 'editor', site_id: @site.id
        assert i.create
        assert u = User.find_by_email('revoke.me@host.com')

        assert_difference 'User.count', -1 do
          assert_difference 'SiteUser.count', -1 do
            delete :revoke_invitation, params: { site_id: @site, id: u.id }
          end
        end
        assert_redirected_to bold_site_settings_site_users_path(@site)
      end

      test 'should not destroy not invited user' do
        assert_no_difference 'User.count' do
          assert_no_difference 'SiteUser.count' do
            assert_raise(ActiveRecord::RecordNotFound) do
              delete :revoke_invitation, params: { site_id: @site, id: @user.id }
            end
          end
        end
      end

    end
  end
end
