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

# Base class for all backend controllers that work in the context of a site
#
# SiteController features:
#
# - selection of current site
class SiteController < BoldController
  include SiteObjects

  layout 'site'

  before_action :require_site
  before_action :check_site_config
  before_action { Bold::Kramdown.preview_mode! }

  around_action :use_user_time_zone

  rescue_from Bold::SiteNotFound, with: :select_site


  private

  def require_site
    Bold.current_site = find_current_site
    unless site_selected?
      redirect_to bold_sites_path and return false
    end
  end

  def find_current_site
    if id = (params[:site_id] || site_object&.site_id)
      current_user.sites.find_by_id id
    end
  end

  def check_site_config
    return unless site_selected?
    unless current_site.theme_config.configured?
      flash[:info] = 'site_not_configured'

      redirect_to edit_bold_settings_theme_path(current_site.theme_name)
      return false
    end
  end

  def select_site
    if Site.any?
      redirect_to bold_sites_url
    else
      start_setup
    end
  end


end

