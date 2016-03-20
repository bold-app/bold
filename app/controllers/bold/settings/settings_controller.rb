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
class Bold::Settings::SettingsController < Bold::SettingsController
  skip_before_action :check_site_config
  helper 'admin/sites'

  def edit
    @site = current_site
  end

  def update
    @site = current_site
    if @site.update_attributes(site_params)
      redirect_to bold_site_settings_root_path(@site), notice: :saved
    else
      render 'edit'
    end
  end

  def favicon
    @assets = current_site.assets.images.order('created_at DESC').
      where("file_size < ? AND content_type LIKE '%icon' OR content_type LIKE '%png'", 50.kilobytes).
      page(params[:page]).per(12)
  end

  def logo
    @assets = current_site.assets.images.order('created_at DESC').page(params[:page]).per(12)
  end

  private

  def site_params
    allowed_attributes = Site::CONFIG_ATTRIBUTES + %i( name hostname alias_string homepage_id config ) + [available_locales: []]
    params.require(:site).permit allowed_attributes
  end
end
