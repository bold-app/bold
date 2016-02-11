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
class UserDecorator < Draper::Decorator
  include PostList

  delegate :email, :name, :meta_google_plus, :twitter_handle

  def user_image(size: 80, html: {})
    h.image_tag user_image_url(size), {width: size, height: size, alt: '', class: 'avatar'}.merge(html)
  end

  def user_image_url(size = 80)
    default_url = h.image_url(::Bold::Gravatar::DEFAULT)
    Bold::Gravatar.url object.email, size, default_url
  end

  def path
    if object.name.present?
      h.author_posts_path object.name
    end 
  end

  #
  # Posts
  #

  def _posts
    Site.current.posts.published.ordered.authored_by(object.name)
  end
  private :_posts

  #
  # Metadata
  #
  def meta_tags
    ''.html_safe.tap do |meta|
      meta << h.rel_canonical(canonical_url)
      meta << h.schema_org_meta(name: name, description: description)
      meta << h.og_meta(type: 'profile', url: canonical_url, title: author_name, description: description)
      meta << h.ld_json_tag(meta_ld_json)
    end
  end

  def author_name
    object.meta_author_name.blank? ? object.name : object.meta_author_name
  end


  # TODO optionally include email
  # TODO support multiple author website values (to get more sameAs elements)
  def meta_ld_json(include_context: true)
    {
      '@type': 'Person',
      'name': author_name,
      'image': user_image_url(200),
    }.tap do |meta|
      meta['@context'] = 'http://schema.org' if include_context
      meta['description'] = description if description?

      # we want one url as meta['url'], and the remaining urls as meta['sameAs'] array.
      urls = [
        website.presence,
        meta_google_plus.presence,
      ]
      urls.unshift canonical_url if Site.current.author_page.present?
      urls.compact!
      meta['url'] = urls.shift
      meta['sameAs'] = urls
    end
  end

  def canonical_url
    @canonical_url ||= h.site.canonical_url path
  end
  alias url canonical_url

  # FIXME add more author metadata
  def location
  end
  def description
  end
  def website
  end
  def bio
  end

  def bio?
    bio.present?
  end

  def location?
    location.present?
  end

  def description?
    description.present?
  end

  def website?
    website.present?
  end

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

end