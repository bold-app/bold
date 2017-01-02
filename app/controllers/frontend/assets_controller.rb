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

    before_action :process_cookie, except: :display_config

    # name of the temporary cookie used to transmit dpr and screen size.
    COOKIE = 'boldScreenSize'

    def show
      send_as :inline, version_for_display
    end

    def download
      send_as :attachment, params[:version]
    end

    def favicon
      if ico = current_site.favicon
        send_file ico.diskfile_path, disposition: 'inline; filename=favicon.ico', type: 'image/x-icon'
      else
        render plain: 'not found', status: :not_found
      end
    end

    # sets dpr and screen size through a separate http request. this is just a
    # fallback in case of app mode (navigator.standalone == false -
    # retinaimag.es does it, but why is that necessary?) or, if JS is turned
    # off, through a CSS rule. Usually these values are set through a cookie,
    # see #process_cookie below.
    def display_config
      self.dpr = params[:dpr]
      self.res = params[:res]
      head 204
    end

    private

    def send_as(disposition, version)
      if @asset = current_site.assets.find(params[:id])
        @asset.ensure_version! version
        send_file @asset.diskfile_path(version), disposition: disposition
      end
    end

    def process_cookie
      if c = cookies[COOKIE] and c.present?
        self.dpr, self.res = c.to_s.split('|')
        cookies.delete COOKIE
      end
      true
    end

    # returns the correct version string for the client's display
    def version_for_display
      if version = params[:version] and
        version.present? and
        current_site.adaptive_images? and
        version !~ /(\Aoriginal|_\dx|_mob)\z/ and
        iv = current_site.image_version(version)

        if iv = iv.for_display(dpr: dpr, size: res, mobile: mobile_ua?)
          version = iv.name
        end
      end
      version
    end

    def mobile_ua?
      request.user_agent =~ /mobile/i
    end

    def dpr=(dpr)
      dpr = dpr.to_i
      session[:dpr] = dpr if Bold::ImageVersion::VALID_DPR.include?(dpr)
    end

    def dpr
      session[:dpr] || 1
    end

    def res=(res)
      res = res.to_i
      session[:res] = res if res > 0
    end

    def res
      session[:res]
    end
  end
end
