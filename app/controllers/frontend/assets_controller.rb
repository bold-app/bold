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
module Frontend
  class AssetsController < FrontendController
    rescue_from ActionController::MissingFile, with: :handle_missing_file
    rescue_from ActiveRecord::RecordNotFound,  with: :handle_missing_file

    def show
      send_as :inline
    end

    def download
      send_as :attachment
    end

    def favicon
      if ico = current_site.favicon
        send_file ico.diskfile_path, disposition: 'inline; filename=favicon.ico', type: 'image/x-icon'
      else
        render text: 'not found', status: :not_found
      end
    end

    private

    def send_as(disposition)
      if @asset = current_site.assets.find(params[:id])
        @asset.ensure_version! params[:version]
        send_file @asset.diskfile_path(params[:version]), disposition: disposition
      end
    end

  end
end