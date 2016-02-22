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

# Base class for all controllers
#
# This keeps ApplicationController clean for extensibility, i.e. when building
# an app with features unrelated to Bold.
#
# BaseController features:
#
# - hook functions
class BaseController < ApplicationController

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  prepend DecoratedAssignments
  include Bold::Hooks::Helper
  helper Bold::Hooks::ViewHelper

  include Bold::I18n::AutoLocale
  around_action :set_locale

  private

  def find_current_site_for_user
    user_signed_in? and
      id = session[:current_site_id] and
      current_user.sites.where(id: id).first
  end

  def current_site
    Bold.current_site
  end

  def site_selected?
    current_site.present?
  end

  def handle_error(e)
    raise e
  end

  def handle_404(e)
    raise e
  end

  def handle_missing_file(*args)
    head :not_found
  end

end
