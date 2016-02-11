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
  class SiteUsersController < AdminController
    before_filter :find_user
    decorate_assigned :user, with: 'Bold::UserDecorator'
    decorate_assigned :site_user, with: 'Bold::SiteUserDecorator'

    def new
      @site_user = @user.site_users.build
    end

    def create
      @site_user = @user.site_users.build site_user_params
      if @site_user.save
        render 'update'
      else
        render 'new'
      end
    end

    def edit
      @site_user = find_site_user
    end

    def update
      @site_user = find_site_user
      if @site_user.update_attributes site_user_params
        render 'update'
      else
        render 'edit'
      end
    end

    def destroy
      find_site_user.destroy
      redirect_to admin_user_url(@user)
    end

    private

    def site_user_params
      params[:site_user].permit :site_id, :manager
    end

    def find_site_user
      find_user.site_users.find params[:id]
    end

    def find_user
      @user ||= User.find params[:user_id]
    end


  end
end