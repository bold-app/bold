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
# - redirect to setup / site selection when needed
class BoldController < BaseController
  layout 'bold'

  before_action :authenticate_user!
  before_action { Bold::Kramdown.preview_mode! }

  around_action :use_user_time_zone

  rescue_from Bold::AccessDenied, with: :handle_access_denied
  rescue_from Bold::SetupNeeded, with: :start_setup
  rescue_from Bold::NotFound, with: :handle_404

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
      Bold.current_user = current_user
    else
      raise ::Bold::SetupNeeded
    end
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
    respond_to do |format|
      format.html do
        request.xhr? ? head(401) : redirect_to(new_user_session_url)
      end
      format.any { head 401 }
    end
  end

  def start_setup
    redirect_to new_setup_user_url
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
