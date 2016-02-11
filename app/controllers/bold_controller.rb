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
# Base class for all backend controllers
#
# BoldController features:
#
# - authentication
# - selection of current site based on session / request host
# - redirect to setup / site selection when needed
class BoldController < BaseController

  layout 'bold'

  before_action :authenticate_user!
  before_action :remember_user
  before_action :set_site
  before_action :require_site
  before_action :remember_current_site
  before_action :check_site_config
  before_action { Bold::Kramdown.preview_mode! }

  around_action :use_user_time_zone

  rescue_from Bold::AccessDenied, with: :handle_access_denied
  rescue_from Bold::SetupNeeded, with: :start_setup
  rescue_from Bold::SiteNotFound, with: :goto_admin
  rescue_from Bold::NotFound, with: :handle_404

  helper_method :current_site

  private

  def use_user_time_zone(&block)
    if user_signed_in? and tz = current_user.time_zone
      Chronic.time_class = tz
      Time.use_zone(tz, &block)
    else
      block.call
    end
  end

  def authenticate_user!
    if User.any?
      super
    else
      raise ::Bold::SetupNeeded
    end
  end

  def remember_user
    Bold.current_user = current_user
  end

  # require a global admin
  def require_admin!
    user_signed_in? && current_user.admin? or raise Bold::AccessDenied
  end

  # require a site admin
  def require_site_admin!
    user_signed_in? && current_user.site_admin? or raise Bold::AccessDenied
  end

  def handle_access_denied
    sign_out
    reset_session
    redirect_to new_user_session_url and return false
  end

  def goto_admin
    if Site.any?
      redirect_to select_admin_sites_url
    else
      start_setup
    end
  end

  def start_setup
    redirect_to new_setup_user_url
  end

  def set_site
    Bold.current_site = find_current_site || (Rails.env.development? && Site.first)
  end

  def find_current_site
    find_current_site_for_user ||
      (user_signed_in? && current_user.sites.one? && current_user.sites.first) # Site.for_hostname(request.host)
  end

  def require_site
    unless site_selected?
      redirect_to select_admin_sites_path and return false
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

  def remember_current_site
    session[:current_site_id] = current_site.id if site_selected?
  end

  def memento(undo_template: nil, &block)
    super &block
    if undo_id = response.headers['X-Memento-Session-Id']
      flash[:undo_id] = undo_id
    end
    if undo_template
      undo_with undo_template
    end
  end

  # saves the given string as undo_template attribute in the current memento
  # session, if any.
  def undo_with(template)
    if undo_id = response.headers['X-Memento-Session-Id']
      current_user.undo_sessions.
        find(undo_id).update_attribute :undo_info, template
    end
  end

end