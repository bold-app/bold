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
module Frontend
  module MetadataHelper

    def rel_canonical(url)
      tag(:link, rel: 'canonical', content: url) + "\n".html_safe
    end

    def ld_json_tag(data = {})
      "\n".html_safe << content_tag(:script, type: 'application/ld+json') do
        raw data.to_json
      end << "\n".html_safe
    end

    def simple_meta(data = {})
      meta_map(data) do |name, content|
        tag :meta, name: name, content: content
      end
    end

    # OpenGraph meta data (http://ogp.me/)
    #
    # Bold by default renders OpenGraph meta data so there is no need to call
    # this method yourself in your templates.
    #
    # The only exception from this rule is the `og:image` tag. Where possible,
    # your template should render that using an image from either the template
    # fields (as the Casper theme does with the cover image in it's post
    # template) or by getting some image from the post content. See
    # `og_meta_tag` for how to add such a single og meta tag.
    #
    # TODO: provide a helper for getting a list of images that are referenced
    #       in a post's body.
    #
    def og_meta(data = {})
      data[:site_name] ||= site.name
      meta_map(data) do |name, content|
        Array(content).map do |value|
          og_meta_tag name, value
        end.join("\n".html_safe)
      end
    end

    # Schema.org meta data
    #
    # Bold by default renders Schema.org meta data as ld+json.
    # Use this method to render custom `meta itemprop...` tags.
    def schema_org_meta(data = {})
      meta_map(data) do |name, content|
        tag :meta, itemprop: name, content: content
      end
    end

    # Renders a single OpenGraph meta tag.
    #
    #
    #     - content_for :html_head do
    #       = og_meta_tag :image, post.image_path(:cover_image, size: :original)
    #
    def og_meta_tag(name, content)
      tag :meta, property: "og:#{name}", content: content
    end


    # Twitter card metadata
    #
    # Bold always renders og meta data for posts and pages.
    # Themes can, where desired, easily add twitter card meta data to their
    # templates using this method:
    #
    #     - content_for :html_head do
    #       = tw_meta 'summary_large_image'
    #
    # Site and creator twitter handles are added automatically if set. Since
    # Twitter will fall back to og meta data if necessary and Bold always
    # renders that, it is not necessary to specify title and description here.
    # Also the `og:image` meta tag will be interpreted by twitter, so if your
    # template renders that you are all set with the simple call above.
    #
    def tw_meta(card_type, data = {})
      data.reverse_merge! creator: content.author_twitter_handle,
                          site: content.site_twitter_handle,
                          card: card_type
      meta_map(data) do |name, content|
        tw_meta_tag name, content
      end
    end

    # Renders a Twitter card meta tag
    #
    # See https://dev.twitter.com/cards/markup
    def tw_meta_tag(name, content)
      tag :meta, name: "twitter:#{name}", content: content
    end


    # Helper method to reject empty attributes and concatenate tags with
    # newlines.
    def meta_map(data = {})
      (data.map do |name, content|
        yield name, content if content.present?
      end.compact.join("\n") + "\n\n").html_safe
    end
  end

end