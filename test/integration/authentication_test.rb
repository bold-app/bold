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

class AuthenticationTest < BoldIntegrationTest

  test 'should send password reset link' do
    visit '/bold'

    click_on 'Forgot your password?'
    fill_in 'Email address', with: 'foo'
    assert_no_enqueued_jobs do
      click_on 'Send me reset password instructions'
    end

    click_on 'Forgot your password?'
    fill_in 'Email address', with: @user.email
    assert_enqueued_jobs 1 do
      click_on 'Send me reset password instructions'
    end
  end

  test 'should invite new user' do
    login_as @admin
    visit '/bold'
    click_link 'Settings'
    click_link 'Users'
    click_link 'new-user'
    fill_in 'invitation_email', with: 'new_user@test.com'
    assert_enqueued_jobs 1 do
      click_on 'Send invitation'
    end
    assert token = enqueued_jobs.last[:args][-2]

    assert u = User.find_by_email('new_user@test.com')
    assert_equal 1, u.site_users.size
    assert_equal @site, u.sites.first
    assert !u.site_users.first.manager?
    assert !u.site_admin?(@site)

    logout

    visit accept_user_invitation_url(:invitation_token => token)

    fill_in 'Password', with: 'password'
    fill_in 'Confirm your new password', with: 'password'
    click_button 'Set My Password'
    assert_equal '/users/sign_in', current_path

    fill_in 'Email address', with: 'new_user@test.com'
    fill_in 'Password', with: 'password'
    click_button 'Sign in'
    assert_equal '/bold', current_path
    assert has_content?('Pages')
    assert has_content?('Posts')
    assert !has_content?('Settings')
  end

end
