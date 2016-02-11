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

class UserTest < ActiveSupport::TestCase

  setup do
    @user = create :confirmed_user
  end

  test 'email address change should invalidate reset password tokens' do
    old_email = @user.email
    new_email = 'user+new@host.com'
    token = nil

    # request password reset
    assert_enqueued_jobs 1 do
      token = @user.send_reset_password_instructions
    end
    @user.reload
    assert @user.valid_password?('secret.1')

    # change email and confirm
    assert_enqueued_jobs 1 do
      assert @user.update_with_password(current_password: 'secret.1', email: new_email)
    end
    @user.reload
    assert_equal old_email, @user.email
    assert_equal new_email, @user.unconfirmed_email
    assert token = enqueued_jobs.last[:args][4]
    confirmed_user = User.confirm_by_token token
    assert_equal @user.id, confirmed_user.id

    assert_equal new_email, confirmed_user.email
    assert_nil confirmed_user.unconfirmed_email

    # mail address change should have invalidated the reset password token
    assert_nil confirmed_user.reset_password_token
  end

  test 'password change should invalidate reset password tokens' do
    token = nil

    # request password reset
    assert_enqueued_jobs 1 do
      token = @user.send_reset_password_instructions
    end
    @user.reload
    assert @user.reset_password_token.present?

    # change password
    assert @user.update_with_password(current_password: 'secret.1', password: 'secret.2', password_confirmation: 'secret.2')
    @user.reload

    assert @user.valid_password?('secret.2')
    assert_nil @user.reset_password_token
  end

end