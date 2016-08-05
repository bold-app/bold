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
class Setup::SitesController < SetupController

  before_action :require_admin!
  before_action :check_if_any_sites

  def new
    @site = Site.new( name: request.host, hostname: request.host )
  end

  def create
    @site = Site.new site_params
    r = CreateSite.call @site
    if r.site_created?
      redirect_to bold_site_path(@site)
    else
      flash.now[:alert] = r.error_message
      render 'new'
    end
  end

  private

  def site_params
    params.require(:site).permit :name, :hostname, :scheme, :theme_name, :aliases
  end

  def check_if_any_sites
    if Site.any?
      redirect_to bold_sites_url and return false
    end
  end

end
