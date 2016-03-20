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


# Base class for controllers delivering content to the public
#
# Does site lookup by hostname / alias and runs requests in the context of the
# site's configured time zone and locale.
class FrontendController < BaseController

  layout :determine_layout

  prepend_before_action :set_site
  around_action :use_site_time_zone
  after_action  :log_request

  # order matters, least specific has to be first
  rescue_from Exception, with: :handle_error
  rescue_from Bold::SetupNeeded, with: :handle_404
  rescue_from Bold::NotFound, with: :handle_404
  rescue_from Bold::SiteNotFound, with: :handle_404_or_goto_admin
  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_error
  rescue_from ActionController::UnknownFormat, with: :handle_404

  decorate_assigned :site, :content, :tag, :author, :category

  private

  def find_content
    if params[:path].blank?
      current_site.homepage
    elsif @permalink = current_site.permalinks.find_by_path(params[:path])
      @destination = @permalink.destination
      (@destination.is_a?(Content) && @destination.published?) ?
        @destination : nil
    end
  end

  def render_content(content = @content, options = {})
    original_content = @content
    @content = content
    options[:status] ||= :ok
    respond_to do |format|
      format.html do
        options[:template] = content.get_template.file
        render options
      end
      format.any { head options[:status] }
    end
    @content = original_content
  end

  def determine_layout
    current_site.theme.layout.present? ? 'content' : 'default_content'
  end

  def handle_404_or_goto_admin
    if request.host == Bold::Config['backend_host']
      redirect_to bold_sites_url
    else
      handle_404
    end
  end

  # Finds the current site based on http host or server_name header
  #
  # For the dev environment there is a fallback to the first site
  # found when none matched. Other environments will yield a
  # SiteNotFound error instead.
  #
  # Override #find_current_site or Site::for_request to customize the
  # detection of the current site.
  def set_site
    @site = Bold.current_site = find_current_site
    raise Bold::SiteNotFound unless site_selected?
  end

  def available_locales
    super.tap do |locales|
      if (site_locales = current_site.available_locales).present?
        locales &= site_locales
      end
    end
  end

  def auto_locale
    if current_site.detect_user_locale?
      return http_accept_language.compatible_language_from available_locales
    end
  end


  def use_site_time_zone(&block)
    if site_selected?
      current_site.in_time_zone &block
    else
      block.call
    end
  end

  def find_current_site
    Site.for_hostname(request.host)
  end

  def handle_404(*args)
    # we enforce rendering of html even if it was an image or something else
    # that wasn't found.
    if site = Bold.current_site and page = site.notfound_page
      render_content page, status: :not_found
    else
      respond_to do |format|
        format.html {
          render 'errors/404', layout: 'error', status: 404, formats: :html
        }
        format.any { head status: :not_found }
      end
    end
    log_request
  end

  def handle_error(*args)
    if site = Bold.current_site and page = site.error_page
      render_content page, status: 500, formats: :html
    else
      render 'errors/500', layout: 'error', status: 500, formats: :html
    end
    if exception = args.first
      Rails.logger.warn exception
      Rails.logger.info exception.backtrace.join("\n")
    end
    log_request
  end

  def handle_missing_file(*args)
    super
    log_request
  end

  def do_not_track?
    request.headers['DNT'] == '1'
  end

  def log_request
    if site = Bold.current_site and request.get? and !(do_not_track? and site.honor_donottrack)
      visitor_id = session[:visitor_id]
      content = (@content || @asset)
      content = content.object if content.respond_to?(:object)
      r = site.request_logs.create req: request, res: response, resource: content, permalink: (@permalink || content.try(:permalink)), visitor_id: visitor_id
      if visitor_id.nil?
        # a new visitor_id has been generated on insert
        session[:visitor_id] = RequestLog.where(id: r.id).pluck(:visitor_id).first
      end
    end
  end

end
