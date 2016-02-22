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
module Admin
  class UsersController < AdminController

    before_action :deny_current_user, only: %i(lock reset_password destroy unlock)
    decorate_assigned :user, :users, with: 'Bold::UserDecorator'

    def index
      @users = User.active.by_name
    end

    def locked
      @users = User.locked.by_name
    end

    def show
      @user = find_user
    end

    def edit
      @user = find_user
    end

    def update
      @user = find_user
      if @user.update_attributes user_params
        render 'update'
      else
        render 'edit'
      end
    end

    def lock
      user = find_user
      user.lock_access! send_instructions: false
      redirect_to admin_user_url user
    end

    def unlock
      user = find_user
      user.unlock_access!
      redirect_to admin_user_url user
    end

    def reset_password
      user = find_user
      user.update_attribute :password, SecureRandom.hex(32)
      user.send_reset_password_instructions
      flash[:info] = t 'flash.admin.reset_user_password', email: user.email
      redirect_to admin_user_url(user)
    end

    def destroy
      find_user.destroy
      redirect_to admin_users_url
    end

    private

    def deny_current_user
      if find_user == current_user
        redirect_to admin_user_url and return false
      end
    end

    def user_params
      params[:user].permit :email, :name, :admin
    end

    def find_user
      @user ||= User.find params[:id]
    end

  end
end
