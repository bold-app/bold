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
  class InvitationsControllerTest < ActionController::TestCase

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
      get :new
      assert_access_denied

      sign_in :user, user
      post :create, user: {}
      assert_access_denied

      sign_in :user, user
      delete :destroy, id: @admin.id
      assert_access_denied
    end

    test "should get index" do
      site = create :site
      user = create_invited_user site
      get :index, {}, { current_site_id: @site.id }
      assert_response :success
      assert_select 'td', /^#{user.email}/
    end

    test "should get new" do
      xhr :get, :new
      assert_response :success
      assert_select 'h4', /Invite user/
    end

    test 'should invite user' do
      site = create :site
      assert_enqueued_jobs 1 do
        xhr :post, :create, { invitation: { email: Faker::Internet.email, role: 'manager', site_id: site.id } }, { current_site_id: @site.id }
      end
    end

    test 'should invite user again' do
      site = create :site
      user = create_invited_user site
      assert_enqueued_jobs 1 do
        patch :update, { id: user.to_param }, { current_site_id: @site.id }
      end
      assert_redirected_to admin_invitations_url
    end

    private

    def create_invited_user(site, role = 'editor')
      i = Invitation.new email: Faker::Internet.email, role: role, site_id: site.id
      assert i.create
      User.find_by_email i.email
    end
  end
end