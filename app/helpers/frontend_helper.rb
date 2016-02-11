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

require 'cgi'

module FrontendHelper
  include Frontend::MetadataHelper

  def site
    @site
  end

  def content
    @content
  end

  alias page content
  alias post content

  def category
    @category
  end

  def current_tag
    @tag
  end

  def current_search
    if content == site.search_page
      @content_search ||= PublicContentSearch.new params[:q]
    end
  end

  def search_form_tag(path = nil, options = {}, &block)
    return unless site.search_enabled?
    path ||= content_path site.search_page.path
    options.reverse_merge! method: :get
    form_tag path, options, &block
  end

  def author
    @author
  end

  def archive
    params[:year].present? ? site.archive : nil
  end

  def theme_layout
    Site.current.theme.layout_path || 'default_content'
  end

  # true if this is page 2 or more of a listing
  def paged?
    params[:page].to_i > 1
  end

  # the current list of posts. limit and page options are only taken into
  # account on the first call and are ignored afterwards.
  def post_list(limit: 10, page: params[:page])
    @post_list ||= (current_search || current_tag || category || author || archive || site).posts(limit: limit, page: page)
  end


  # link to a page or post, by giving the object or its slug. second
  # parameter may be the link text (which defaults to the content's title)
  # any following arguments are passed to link_to
  def content_link(content, *args)
    content = Content[content] if String === content
    content.decorate.link_to *args if content
  end

  # Comment form builder
  #
  #     = comment_form do |f|
  #       = f.input :author_name
  #       = f.input :author_email
  #       = f.input :author_website
  #       = f.input :body
  #       = f.button :submit, 'Comment'
  #
  def comment_form(options = {}, &block)
    content = options.delete(:content) || @content
    anchor = options.delete(:anchor) || 'new_comment'
    if content.respond_to?(:commentable?) && content.commentable?
      @comment ||= Comment.new
      simple_form_for @comment, { url: content_url(content.path, anchor: anchor), builder: Bold::Views::CommentFormBuilder }.merge(options), &block
    end
  end

  # Contact form builder
  #
  #     = contact_form do |f|
  #       = f.input :sender_name
  #       = f.input :sende_email
  #       = f.input :subject
  #       = f.input :body
  #       = f.button :submit, 'Send'
  #
  # Note that the form will only be rendered if the current content has its
  # `contact_message_receiver` field set (which in turn has to be declared by
  # the contents template).
  # This allows for easy disabling of contact forms without changing the
  # template, and it prevents spambots from blindly posting contact messages to
  # pages that don't have a form at all.
  def contact_form(options = {}, &block)
    content = (options.delete(:content) || @content).object
    anchor = options.delete(:anchor) || 'new_contact_message'
    if content.template_field_value?(:contact_message_receiver)
      @contact_message ||= ContactMessage.new
      simple_form_for @contact_message, { url: contact_messages_url(content.path, anchor: anchor) }.merge(options), &block
    end
  end

  # renders a time tag for the given datetime object, formatting it according
  # to the format option
  #
  #     time_tag post.post_date
  #     time_tag post.post_date, format: :date_long
  #     time_tag post.post_date, format: '%B %Y'
  #
  # See #format_date for how to define custom date formats that can be
  # referenced with a symbol like in the second example.
  #
  def time_tag(datetime, format: :default, html: {})
    html[:datetime] ||= datetime.iso8601
    content_tag :time, format_date(datetime, format), html if datetime
  end

  def archive_link(year: nil, month: 1, date_format: :month_long)
    link_to format_date(Time.zone.local(year, month, 1).to_date, date_format),
      archive_path(year,  ('%02d' % month.to_s))
  end

  def image(asset, size: :bold_thumb, default: nil, html: {})
    asset = site.find_asset(asset) if String === asset
    if asset && asset.image? && asset.readable?
      image_tag site.image_path(asset, size: size), {alt: asset.title}.merge(html)
    elsif default
      image_tag default, html
    end
  end

  # Formats a date (or datetime)
  #
  # If format is `nil`, the default pattern of `%d. %B, %H:%M` is used.
  #
  # If format is a String, it is used as strftime pattern.
  #
  # If format is a Symbol, the format string to be used is looked up via
  # Rails' I18n mechanism, for example:
  #
  # Given a time object and a format value of `:date_long`, the following I18n
  # keys will be tried:
  #
  # - themes.<current-theme>.time.formats.date_long
  # - time.formats.date_long
  # - time.formats.short
  #
  # If the first argument is actually a `Date`, `date` will be used
  # instead of `time` in the above I18n keys.
  #
  def format_date(datetime, format = nil)
    pattern = "%d. %B, %H:%M"
    pattern = format if String === format
    if datetime
      if Symbol === format
        kind = datetime.respond_to?(:sec) ? 'time' : 'date'
        keys = [
          "#{kind}.formats.short"
        ]
        if format.present?
          keys.unshift "#{kind}.formats.#{format}"
          keys.unshift "themes.#{Site.current.theme_name}.#{kind}.formats.#{format}"
        end
        keys.each do |key|
          begin
            pattern = I18n.t(key, raise: true)
            break
          rescue I18n::MissingTranslationData
            next
          end
        end
      end
      localize datetime, format: pattern
    end
  end
  alias d format_date

  def bold_logo(logo: 'bold/logo_tiny.png', text: nil, html: {})
    h(text.to_s) +
      link_to(image_tag(logo, {alt: Bold.application_name, class: 'bold-logo'}.merge(html)), Bold.application_url)
  end

  def tt(*args)
    Bold::I18n.t *args
  end

  # 'now' in the site's time zone
  def now
    Time.zone.now
  end

  # Returns the primary object of this request.
  #
  # Trys category, tag, author, archive first before returning the current
  # page / post if none of these is present.
  def displayed_object
    category || current_tag || author || archive || content
  end


  # Layout helpers
  #
  # These output site metadata and content rendered via hooks, as well as
  # configured pre- and post html snippets.
  #
  # Be sure to include them when you roll your own layout.
  #
  def bold_meta
    site.site_meta_tags.tap do |out|
      if o = displayed_object and o.respond_to?(:meta_tags) and response.status == 200 # dont bother outputting meta tags on error pages
        out << o.meta_tags
      end
      out << site.html_head_snippet.to_s.html_safe
      out << call_hook(:view_layout_html_head)
    end
  end

  def bold_header
    site.body_start_snippet.to_s.html_safe <<
      call_hook(:view_layout_body_start)
  end

  def bold_footer
    call_hook(:view_layout_body_end) <<
      site.body_end_snippet.to_s.html_safe
  end

  def percent_encode(string)
    URI.escape string
  end

  def flash_message
    safe_join %i( alert warning info notice ).map{ |key|
      if msg = flash[key]
        content_tag :p, msg, class: "flash #{key}"
      end
    }.compact
  end
end
