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
class TagDecorator < Draper::Decorator
  include PostList

  delegate :name, :path

  #
  # Linking to this tag
  #

  def link_to(*args)
    options = args.extract_options!
    title = args.shift || name
    args.push options
    h.link_to title, h.content_path(path), *args
  end

  #
  # Metadata
  #
  def meta_tags
    name = "Tag: #{name}"
    ''.html_safe.tap do |meta|
      meta << h.rel_canonical(canonical_url)
      meta << h.og_meta(type: 'website', url: canonical_url, title: name)
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
      'description' => "Posts tagged #{name}",
      'url' => canonical_url,
    }
  end


  #
  # Posts
  #

  def _posts
    Site.current.posts.published.ordered.tagged_with(self.name)
  end
  private :_posts

end