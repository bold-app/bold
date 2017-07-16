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
class SiteDecorator < Draper::Decorator
  include PostList
  delegate :name, :theme_name, :body_start_snippet, :body_end_snippet, :tags, :search_page, :site_js


  # global meta tags and other html-head things rendered on every page
  def site_html_head_tags
    h.csrf_meta_tags.to_s.tap do |output|
      output << "\n"
      if object.favicon.present?
        output << h.tag(:link, rel: 'shortcut icon', href: h.favicon_url, type: 'image/x-icon') << "\n"
      end
      output << h.tag(:meta, name: 'generator', content: "Bold #{Bold::VERSION}") << "\n"
      if object.site_css.present?
        output << h.stylesheet_link_tag(h.site_content_path(format: :css))
      end
      unless h.do_not_track? && object.honor_donottrack?
        output << h.javascript_include_tag('ahoy_standalone')
      end
      if object.adaptive_images?
        output << h.render('layouts/highres_support')
      end
      output << object.html_head_snippet.to_s.html_safe
    end
  end

  def meta_ld_json
    {
      'publisher' => object.name,
    }.tap do |meta|
      if search_enabled?
        path = h.content_path object.search_page.path
        meta["potentialAction"] = {
          "@type"  => "SearchAction",
          "target" => object.external_url(path) + '?q={search_term_string}',
          "query-input" =>  "required name=search_term_string"
        }
      end
    end
  end

  def canonical_url(path = '')
    object.external_url(path)
  end
  alias url canonical_url

  def last_mod_date
    object.contents.published.order('updated_at DESC').first.updated_at
  end

  #
  # Navigation
  #

  def navigation
    @navigation ||= NavigationsDecorator.decorate site.navigations
  end

  def navigation?
    navigation.any?
  end

  #
  # Posts
  #

  def _posts
    object.posts.published.ordered
  end
  private :_posts

  def archive(y = h.params[:year], m = h.params[:month])
    @archive ||= Bold::Archive.new site: object, year: y, month: m
  end

  #
  # Tags
  #

  def tag_cloud
    Bold::Tags.new self
  end


  #
  # Images
  #

  def find_asset(id)
    object.assets.find_by_id id if id
  end

  def image_path(asset, size: :original, default: nil)
    asset = find_asset(asset) if String === asset
    if asset
      h.file_path(asset, version: size)
    else
      default
    end
  end

  def logo_tag(html_options = {})
    h.image_tag image_path(object.logo), {alt: object.name, class: 'brand'}.merge(html_options)
  end

  def logo?
    object.logo_id.present?
  end

  #
  # Search
  #
  def search_enabled?
    search_page.present?
  end


  #
  # Theme and plugin variables
  #

  # returns the theme config variable named `key`
  def theme_value(key)
    object.theme_config.config[key.to_s]
  end
  def theme_value?(key)
    object.theme_config.config.key? key.to_s
  end

  # returns the plugin config variable named `key`
  def plugin_value(plugin, key)
    object.plugin_config(plugin).config[key.to_s]
  end
  def plugin_value?(plugin, key)
    object.plugin_config(plugin).config.key? key.to_s
  end

end
