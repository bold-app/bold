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
class CategoryDecorator < Draper::Decorator
  include PostList
  include SrcsetImages

  delegate :name, :description, :path

  def image_path(*_)
    image_path_for_asset object.asset, *_
  end

  # Given the id of a template field holding an image reference, this returns
  # an image tag for that image for the given size.
  # You can specify a fallback image path as +default+.
  def image(size: :original, default: nil, html: {})
    html[:alt] ||= object.asset.title || name
    super object.asset, size: size, default: default, html: html
  end

  def image?
    object.asset.present?
  end

  #
  # Linking to this category
  #

  def link_to(*args, &block)
    options = args.extract_options!
    title = args.shift || name
    args.push options
    if block_given?
      h.link_to h.content_path(path), *args, &block
    else
      h.link_to title, h.content_path(path), *args
    end
  end

  #
  # Metadata
  #

  # TODO make this configurable, i.e. via a pattern in meta title property of
  # category page.
  def meta_title
    @meta_title ||= "#{name} - #{h.site.name}"
  end

  def meta_tags
    ''.html_safe.tap do |meta|
      meta << h.rel_canonical(canonical_url)
      meta << h.simple_meta(description: description)
      meta << h.og_meta(type: 'website', url: canonical_url, title: meta_title, description: description)
      meta << h.ld_json_tag(meta_ld_json)
    end
  end

  def canonical_url
    @canonical_url ||= h.site.canonical_url h.content_path path
  end
  alias url canonical_url

  def meta_ld_json
    {
      '@context' => 'http://schema.org',
      '@type' => 'Series',
      'publisher' => h.site.name,
      'name' => name,
      'description' => description,
      'url' => canonical_url,
    }.tap do |meta|
      meta['image'] = h.site.canonical_url(image_path) if image?
    end
  end

  #
  # Posts
  #

  def _posts
    object.posts.published.ordered
  end
  private :_posts

end
