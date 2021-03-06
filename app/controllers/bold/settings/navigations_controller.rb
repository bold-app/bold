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
class Bold::Settings::NavigationsController < Bold::SettingsController
  helper 'bold/settings'

  prepend_before_action :find_navigation, only: %i(update destroy sort)
  site_object :navigation

  def index
    @navigations = current_site.navigations
    @navigation = Navigation.new url: current_site.external_url
  end

  def create
    @navigation = current_site.navigations.build navigation_params
    if @navigation.save
      @navigation.move_to_bottom
      flash.now[:notice] = 'bold.navigation.created'
    end
  end

  def update
    @navigation.update_attributes navigation_params
    flash.now[:notice] = 'bold.navigation.updated'
  end

  def destroy
    Navigation.transaction do
      memento(undo_template: 'restore_navigation') do
        # prevent 'holes' in position list to make the client-side JS simpler
        @navigation.move_to_bottom
        @navigation.destroy
      end
    end
    flash.now[:notice] = 'bold.navigation.deleted'
  end

  def sort
    # jquery sortable is zero based, while with acts_as_list the first index
    # is 1:
    @navigation.insert_at params[:new_position].to_i + 1
    head :ok
  end

  private

  def find_navigation
    @navigation = Navigation.find params[:id]
  end

  def navigation_params
    params[:navigation].permit :name, :url
  end

end
