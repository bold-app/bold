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
  class SitesController < AdminController

    before_action :require_admin!
    before_action :find_site, only: %i(edit update show destroy)


    def index
      load_sites
      @site = @sites.first || Site.new
    end

    def new
      load_sites
      @site = Site.new
    end

    def create
      @site = Site.new site_params
      result = CreateSite.call(@site)
      if result.site_created?
        redirect_to admin_sites_path
      else
        load_sites
        flash[:alert] = result.error_message
        render :new
      end
    end

    def edit
      load_sites
    end

    # FEATURE generate export in background and show download link in frontend
    #  - separate 'export' model?
    def show
      send_file @site.export!(Rails.root.join('exports'))
    end

    def update
      if @site.update_attributes(site_params)
        redirect_to edit_admin_site_path(@site)
      else
        load_sites
        render :edit
      end
    end

    def destroy
      # Export the site before removal as a final safety net.
      @site.store_backup!
      @site.destroy
      redirect_to admin_sites_path
    end

    private

    def load_sites
      @sites = Site.order('created_at asc')
    end

    def site_params
      params[:site].permit :name, :url_scheme, :hostname, :alias_string, :theme_name
    end

    def find_site
      @site = Site.find params[:id]
    end

  end
end
