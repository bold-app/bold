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

# Helper methods for the Bold backend
module BoldHelper
  include Teambox::Icons::Rails::Helper
  include Bold::Views::GravatarHelper

  def app_title
    'Bold'
  end

  def show_sites_menu?
    current_user.available_sites.many?
  end

  #def public_url(permalinkable)
  #  site = permalinkable.site
  #  root_url(host: site.hostname, port: request.port)[0..-2] + permalinkable.public_path
  #end

  def bold_pagination_for(collection, options = {})
    paginate collection, options.merge(theme: 'twitter-bootstrap-3')
  end

  def asset_tag(asset, version = :bold_thumb, html_class = '')
    # FIXME  show n/a icon for non-readable assets
    if asset.image? && asset.readable?
      path = bold_asset_path(asset, version: version)
      image_tag path, alt: asset.title, class: "#{html_class} #{version}".strip
    elsif mime_type = asset.mime_type
      teambox_icon mime_type, 512
    else
      teambox_icon :_blank, 512
    end
  end

  def icon(name, options = {})
    content_tag :span, '', options.merge(class: "glyphicon glyphicon-#{name.to_s.gsub /_/, '-'}")
  end

  def link_with_icon(icon_name, text, *args)
    args.unshift(icon(icon_name) + '&nbsp;'.html_safe + text)
    options = args.extract_options!
    ((options[:class] ||= '') << ' icon text').strip!
    args << options
    link_to *args
  end

  def placeholder_image_tag(height = 150, ratio = 3/2)
    image_tag 'bold/dummy.gif', width: height*ratio, height: height, alt: t('bold.common.placeholder')
  end

  def nav_link(name, url, criteria = { controller: name })
    controller = criteria[:controller]
    badge = criteria.delete :badge
    action = criteria[:action]
    css_class = 'active' if params[:controller] =~ /#{controller}/ && (action.blank? || params[:action] =~ /#{action}/)
    content_tag :li, class: css_class do
      name = t("bold.common.nav.#{name}") if Symbol === name
      name = h(name)
      if badge.present?
        name << h(' ') << content_tag(:span, badge, class: 'badge')
      end
      link_to name, url
    end
  end

  def l_date_time(date_time)
    I18n.l date_time, format: :bold_ymdt if date_time
  end

  def l_date(date_time)
    I18n.l date_time, format: :bold_ymd if date_time
  end

  def languages_for_select(languages)
    languages.map do |lang|
      [I18n.t("i18n_languages.#{lang}"), lang]
    end.compact.sort {|a, b| a.first <=> b.first }
  end

  def button(label = 'bold.common.save', clazz = 'primary', options = {})
    text = ''.html_safe
    text << icon(options.delete(:icon)) if options[:icon]
    if label.present?
      text << '&nbsp;'.html_safe unless text.blank?
      text << t(label)
    end
    content_tag :button, text, options.merge(class: "#{options.delete :class} btn btn-#{clazz}")
  end

  FLASH_MAPPING = {
    alert: 'error',
    info: 'info',
    notice: 'success'
  }

  # Outputs JS to display flash messages.
  # set wrap_js to true for wrapping the JS in a document.ready call and script
  # tag (use when calling from a layout), leave it false when calling from a JS
  # partial.
  def flash_message(wrap_js: false)
    js = ''
    %i( alert info notice ).each do |key|
      if msg = flash[key]
        # messages without space or uppercase letter are treated as i18n keys
        msg = t("flash.#{msg}") if msg.to_s !~ /[\sA-Z]/

        # Check if this flash is the response to an undoable action. In this
        # case we:
        # - display the 'undo' link next to the message
        # - set the message to disappear after 5 minutes instead of 3/5 seconds.
        undo_id = response.headers['X-Memento-Session-Id'].to_i
        if undo_id == 0
          undo_id = flash[:undo_id].to_i
        end
        js << "toastr.remove();" # avoid stacking of multiple messages
        if undo_id > 0
          link = link_to t('flash.bold.undo.link'), '#', onclick: 'window.bold.undo(this); return false;', rel: bold_site_undo_path(current_site, undo_id)
          js << "toastr.#{FLASH_MAPPING[key]}('#{escape_javascript link}', '#{escape_javascript msg}', { timeOut: 300000, extendedTimeOut: 300000 });"
        else
          js << "toastr.#{FLASH_MAPPING[key]}(null, '#{escape_javascript msg}', { timeOut: 3000, extendedTimeOut: 5000 });"
        end
      end
    end
    flash.clear
    unless js.blank?
      if wrap_js
        javascript_tag "$(document).ready(function(){#{js}});"
      else
        js
      end
    end
  end

  # candidate for backend content decorator
  def content_slug_and_title(content)
    "#{content.path} - #{content.current_title||t('bold.common.untitled')}"
  end

  def edit_Content_link(content, *args)
    link_to content.title, edit_content_path(content), *args
  end

  def public_content_link(content, *args)
    link_to content_slug_and_title(content), content.public_url, *args
  end

  def edit_content_path(content)
    case content
    when Post
      edit_bold_post_path(content)
    when Page
      edit_bold_page_path(content)
    end
  end

  def dynamic_configuration_form_for(record, options = {}, &block)
    simple_form_for record, { builder: Bold::Views::DynamicConfigFormBuilder }.merge(options), &block
  end

  def open_modal(*args)
    %|$('#modal').html('#{escape_javascript render *args}').modal({backdrop: 'static'});|.html_safe
  end

  def more_link(list = @contents, parameters = {})
    link_to t('common.more'), parameters.merge(page: list.next_page), remote: true, class: 'btn btn-default btn-sm'
  end

  def content_form_url(content = @content)
    case content
    when Post
      content.new_record? ? bold_site_posts_path(current_site) : bold_post_path(@content)
    when Page
      content.new_record? ? bold_site_pages_path(current_site) : bold_page_path(@content)
    end
  end

  def diff_path(content)
    Post === content ? diff_bold_post_path(content) : diff_bold_page_path(content)
  end

  def listgroup_item(label, path, &block)
    link_to label, path, class: "list-group-item#{' active' if yield}"
  end
end
