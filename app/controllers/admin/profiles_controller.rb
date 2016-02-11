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
  class ProfilesController < AdminController
    skip_before_filter :require_admin!
    before_action :set_user

    def edit
    end

    def edit_email
    end

    def edit_password
    end

    def update
      if @user.update_without_password params[:user].permit(:name, :meta_author_name, :meta_google_plus, :twitter_handle, :time_zone_name, :backend_locale, :author_page_id, :vim_mode)
        redirect_to edit_admin_profile_path, notice: 'admin.profile_saved'
      else
        render 'edit'
      end
    end

    def update_email
      if @user.update_with_password params[:user].permit(:email, :current_password)
        redirect_to edit_email_admin_profile_path, notice: 'admin.email_changed'
      else
        render 'edit_email'
      end
    end

    def update_password
      if @user.update_with_password params[:user].permit(:password, :password_confirmation, :current_password)
        redirect_to edit_password_admin_profile_path, notice: 'admin.password_changed'
      else
        render 'edit_password'
      end
    end

    private

    def set_user
      @user = current_user
    end

  end
end