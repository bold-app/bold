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
module Bold
  module Settings

    class SiteUsersController < SettingsController

      decorate_assigned :active_users, :locked_users, :invited_users, with: 'Bold::UserDecorator'

      def index
        @active_users = current_site.users.active.by_name
        @locked_users = current_site.users.locked.by_name
        @invited_users = current_site.users.invitation_not_accepted.by_name
      end

      def new
        @invitation = Invitation.new
      end

      def create
        @invitation = Invitation.new invitation_params
        if @invitation.create
          redirect_to bold_site_settings_site_users_path(current_site)
        else
          render 'new'
        end
      end

      def resend_invitation
        @user = find_invited_user
        @user.invite! current_user
        redirect_to bold_site_settings_site_users_path(current_site)
      end

      def revoke_invitation
        @user = find_invited_user
        if @user.site_users.where('site_id <> ?', current_site.id).any?
          # invited to different sites at same time
          @user.site_users.where(site_id: current_site.id).destroy
        else
          @user.destroy
        end
        redirect_to bold_site_settings_site_users_path(current_site)
      end

      private

      def find_invited_user
        current_site.users.invitation_not_accepted.find params[:id]
      end

      def invitation_params
        params[:invitation].permit :email, :role
      end

    end
  end
end
