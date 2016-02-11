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
  class ImportsController < AdminController

    before_filter :require_admin!
    before_filter :find_site

    def new
      @site_import = SiteImport.new
    end

    def create
      @site_import = SiteImport.new site_import_params
      unless @site_import.import_into(@site)
        redirect_to new_admin_site_import_path, alert: 'admin.not_imported'
      end
    end

    private

    def site_import_params
      if params[:site_import]
        params[:site_import].permit :zipfile
      elsif params[:local_file]
        { local_file: params[:local_file] }
      else
        {}
      end
    end

    def find_site
      @site = Site.find params[:site_id]
    end

  end
end