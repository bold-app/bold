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
class Setup::UsersController < SetupController

  skip_before_filter :authenticate_user!
  before_filter :check_if_any_users

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    @user.admin = true
    @user.skip_confirmation!
    if @user.save
      sign_in(:user, @user)
      redirect_to new_setup_site_url
    else
      render 'new'
    end
  end

  private

  def user_params
    params.require(:user).permit :email, :password, :password_confirmation, :name
  end

  def check_if_any_users
    if User.any?
      redirect_to new_setup_site_url and return false
    end
  end
end