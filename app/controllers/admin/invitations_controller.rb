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
  class InvitationsController < AdminController

    decorate_assigned :users, with: 'Bold::UserDecorator'

    def index
      @users = User.invited.by_name
    end

    def new
      @invitation = Invitation.new
    end

    # invites a user
    def create
      @invitation = Invitation.new invitation_params
      if @invitation.create
        flash.now[:notice] = t('flash.admin.user_invited', email: @invitation.email)
        respond_to do |format|
          format.js {}
          format.html { redirect_to admin_invitations_path }
        end
      else
        render 'new'
      end
    end

    # resends invitation
    def update
      @user = find_user
      @user.invite! current_user
      redirect_to admin_invitations_path, notice: t('flash.admin.user_invited', email: @user.email)
    end

    def destroy
      find_user.destroy
      redirect_to admin_invitations_url
    end

    private

    def invitation_params
      params[:invitation].permit :site_id, :role, :email
    end

    def find_user
      User.invited.find params[:id]
    end

  end
end
