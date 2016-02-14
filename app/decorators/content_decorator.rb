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
class ContentDecorator < Draper::Decorator

  delegate :title, :title_html, :body_html, :commentable?, :teaser_html, :post_date, :id, :path, :homepage?

  def post?
    Post === object
  end

  def body?
    object.body.present?
  end

  def css_class
    (Post === object ? 'post' : 'page').tap do |s|
      s << " " << tags_class if tags?
      s << " " << object.template << "-template"
      s << " paged" if h.paged?
    end
  end

  #
  # Linking to this content
  #

  # the current url (using host and scheme from the current request)
  def current_url(options = {})
    h.content_url options.merge(path: path)
  end

  # the canonical url using configured primary host and scheme
  def canonical_url
    @canonical_url ||= h.site.canonical_url(homepage? ? '' : h.content_path(path))
  end
  alias url canonical_url

  # renders a link to this post / page
  def link_to(*args)
    options = args.extract_options!
    title = args.shift || object.title
    args.push options
    h.link_to title, h.content_path(path, anchor: options.delete(:anchor)), *args
  end

  #
  # Tags
  #

  def tags?
    tags.any?
  end

  def tags
    @tags ||= object.tags.map{|t| TagDecorator.decorate t}
  end

  def tags_class
    @tags_class ||= object.tags.map{|t| "tag-#{t.slug}"}.join ' '
  end

  def tag_links(glue: ', ', link_opts: {})
    glue = h.h(glue)
    tags.map{|t| t.link_to link_opts }.join(glue).html_safe
  end


  #
  # category
  #

  def category?
    object.respond_to?(:category) and object.category.present?
  end

  def category_link
    category&.link_to
  end

  def category
    object.category.decorate if category?
  end


  # title

  def meta_title
    @meta_title ||= object.meta_title.present? ? object.meta_title : object.title
  end

  # description

  def meta_description
    @meta_description ||= if object.meta_description.present?
      object.meta_description
    elsif object.respond_to?(:teaser_text)
      object.teaser_text 30
    end
  end


  #
  # Teaser / Excerpt
  #
  def teaser?
    object.has_teaser? if object.respond_to?(:has_teaser?)
  end

  # teaser text if present
  def teaser_text
    object.teaser
  end

  # Returns an excerpt, which is either the explicit teaser text, or the first
  # n words of the (rendered, tag-stripped) body content
  def excerpt(words: 20)
    if object.respond_to?(:teaser_text) and teaser = object.teaser_text(words)
      teaser.html_safe
    else
      h.strip_tags(object.body_html).truncate_words words
    end
  end

  #
  # Author
  #
  # renders a link to all posts by this content's author
  def author_link(*args)
    if author = object.author
      if object.site.author_page.present?
        h.link_to author.name, h.author_posts_path(author.name)
      else
        author.name
      end
    end
  end

  def author
    @author ||= object.author&.decorate
  end

  def author_twitter_handle
    object.author&.twitter_handle
  end

  def site_twitter_handle
    object.site.twitter_handle.presence || author_twitter_handle
  end

  #
  # Comments
  #
  def has_comments?
    commentable? && comment_count > 0
  end
  alias comments? has_comments?

  def comment_count
    @comment_count ||= comments.count
  end

  def comments(page = 0, limit = 100)
    CommentsDecorator.decorate object.visible_comments(page, limit)
  end


  #
  # fields
  #
  def [](key)
    object.template_field_value key if object.get_template.field?(key)
  end

  def respond_to_missing?(name, *)
    super || object.get_template.field?(name.to_s.sub(/\?\z/, ''))
  end

  def method_missing(name, *, &block)
    field, question = /\A(.+?)(\?)?\z/.match(name.to_s)&.captures
    if object.get_template.field?(field)
      val = self[field]
      if question
        val.present? and '0' != val
      else
        val
      end
    else
      super
    end
  end

  # Given the id of a template field holding an image reference, this returns
  # an image tag for that image for the given size.
  # You can specify a fallback image path as +default+.
  def image(field_id, size: :original, default: nil, html: {})
    h.image_tag image_path(field_id, size: size, default: default), html
  end

  # Given the id of a template field holding an image reference, this returns
  # the path of that image for the given size.
  # You can specify a fallback image path as +default+.
  def image_path(field_id, size: :original, default: nil)
    h.site.image_path self[field_id], size: size, default: default
  end

  # Given the id of a template field holding an image reference, this returns
  # the url of that image for the given size.
  # You can specify a fallback image path as +default+.
  def image_url(*args)
    h.site.canonical_url image_path(*args)
  end

  #
  # related content
  #
  def next_post
    return unless Post === object
    object.site.posts.alive.published.where('post_date > ?', object.post_date).order('post_date ASC').first&.decorate
  end

  # FIXME actually suggest something here based on category / tags / content
  def suggested_post
    return unless Post === object
    prev_post
  end

  def prev_post
    return unless Post === object
    object.site.posts.alive.published.where('post_date < ?', object.post_date).order('post_date DESC').first&.decorate
  end

  def meta_pub_date
    @meta_pub_date ||= object.post_date.iso8601 if object.post_date
  end

  def meta_mod_date
    @meta_mod_date ||= object.last_update.iso8601 if object.last_update
  end

  # meta data
  #
  # author and description meta tags
  # Schema.org microdata: name, datePublished and description
  # OpenGraph (ogp.me): title, type (webpage (Pages) or article (Posts)),
  # published_time and tags for Posts, url
  #
  # TODO figure out a way to find an image to link to in ld and og/twitter
  # meta data from template fields and/or images referenced in body.
  #
  def meta_tags
    ''.html_safe.tap do |meta|
      meta << h.rel_canonical(canonical_url)

      meta << h.simple_meta(description: meta_description, author: author&.author_name)

      # Open graph
      og_meta = {
        title: meta_title,
        description: meta_description,
        url: canonical_url,
        site_name: h.site.name
      }

      # Posts get a little extra
      if Post === object
        og_meta.update type: 'article',
          'article:tag' => object.tags.map(&:name),
          'article:published_time' => meta_pub_date,
          'article:modified_time' => meta_mod_date

        if author and author.meta_google_plus.present?
          meta << h.tag(:link, rel: 'author', content: author.meta_google_plus)
        end
      else
        og_meta[:type] = 'website'
      end

      meta << h.og_meta(og_meta)

      # Schema.org metadata in ld+json format
      meta << h.ld_json_tag(meta_ld_json)
    end
  end

  # TODO make @type configurable and/or specified by template. some people
  # might prefer the more specific BlogPosting over Article or want to use
  # entirely different constructs
  def meta_ld_json(image: nil)
    {
      '@context' => 'http://schema.org',
      'publisher' => h.site.name,
      'headline' => meta_title,
      'description' => meta_description,
      'url' => canonical_url,
      'datePublished' => meta_pub_date,
      'dateModified' => meta_mod_date,
    }.tap do |meta|
      meta['@type'] = if Post === object
        'Article' # BlogPosting? 
      elsif homepage?
        'WebSite'
      else
        'WebPage'
      end
      meta['image'] = image if image
      meta['keywords'] = tags.map(&:name) if tags?
      meta['author'] = author&.meta_ld_json(include_context: false)
    end
  end

end
