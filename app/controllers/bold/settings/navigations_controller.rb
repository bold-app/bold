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

  def index
    @navigations = current_site.navigations
    @navigation = Navigation.new url: current_site.external_url
  end

  def create
    @navigation = Navigation.new navigation_params, site: current_site
    if @navigation.save
      @navigation.move_to_bottom
      flash.now[:notice] = 'bold.navigation.created'
    end
  end

  def update
    @navigation = current_site.navigations.find params[:id]
    @navigation.update_attributes navigation_params
    flash.now[:notice] = 'bold.navigation.updated'
  end

  def destroy
    @navigation = current_site.navigations.find params[:id]
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
    @navigation = current_site.navigations.find params[:id]
    # jquery sortable is zero based, while with acts_as_list the first index
    # is 1:
    @navigation.insert_at params[:new_position].to_i + 1
    render nothing: true
  end

  private

  def navigation_params
    params[:navigation].permit :name, :url
  end

end