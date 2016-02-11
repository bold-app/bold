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

module Bold
  module Kramdown

    class HtmlConverter < ::Kramdown::Converter::Html

      # overridden to support @options[:link_attributes], i.e. for adding
      # rel=nofollow to all links
      def convert_a(el, indent)
        res = inner(el, indent)
        attr = el.attr.dup
        if attr['href'].start_with?('mailto:')
          mail_addr = attr['href'][7..-1]
          attr['href'] = obfuscate('mailto') << ":" << obfuscate(mail_addr)
          res = obfuscate(res) if res == mail_addr
        end
        if link_attributes = options[:link_attributes]
          attr.update link_attributes
        end
        format_as_span_html(el.type, attr, res)
      end

      # overridden to render code blocks as figures
      # http://kalifi.org/2015/04/html5-markdown-kramdown.html
      def convert_codeblock(el, indent)
        attr = el.attr.dup
        ((attr['class'] ||= '') << ' code').strip!
        caption = extract_caption_from_attrs! attr
        lang = extract_code_language!(attr)
        highlighted_code = highlight_code(el.value, lang, :block)

        if highlighted_code
          add_syntax_highlighter_to_class_attr(attr)
          "#{' '*indent}<figure#{html_attributes(attr)}>#{caption}<pre class=\"highlight\"><code>#{highlighted_code}#{' '*indent}</code></pre></figure>\n"
        else
          result = escape_html(el.value)
          result.chomp!
          if el.attr['class'].to_s =~ /\bshow-whitespaces\b/
            result.gsub!(/(?:(^[ \t]+)|([ \t]+$)|([ \t]+))/) do |m|
              suffix = ($1 ? '-l' : ($2 ? '-r' : ''))
              m.scan(/./).map do |c|
                case c
                when "\t" then "<span class=\"ws-tab#{suffix}\">\t</span>"
                when " " then "<span class=\"ws-space#{suffix}\">&#8901;</span>"
                end
              end.join('')
            end
          end
          code_attr = {}
          code_attr['class'] = "language-#{lang}" if lang
          "#{' '*indent}<figure#{html_attributes(attr)}>#{caption}<pre><code#{html_attributes(code_attr)}>#{result}\n</code></pre></figure>\n"
        end
      end

      def convert_img(el, indent)
        slug, size, link_to = el.attr['src'].to_s.split('!')
        if site = Site.current and asset = site.assets.where('slug = :slug OR file = :slug', slug: slug).first
          attr = el.attr.dup
          attr['src'] = image_path asset, size

          if size.present?
            ((attr['class'] ||= '') << ' ' << size).strip!
          end

          image_tag = "<img#{html_attributes(attr)} />"

          if link_to.present?
            link = if asset.site.has_image_version?(link_to)
              asset.public_path link_to
            else
              link_to
            end
            return "#{' '*indent}<a#{html_attributes href: link}>#{image_tag}</a>"
          else
            return (' '*indent) + image_tag
          end
        end
        super
      end

      # overridden to render block level images as figures
      # http://kalifi.org/2015/04/html5-markdown-kramdown.html
      def convert_p(el, indent)
        if el.options[:transparent]
          inner(el, indent)
        # Check if the paragraph only contains an image and treat it as a
        # figure instead.
        elsif el.children&.count == 1 && el.children.first.type == :img
          render_figure_img el.children.first, indent
        else
          format_as_block_html(el.type, el.attr, inner(el, indent), indent)
        end
      end

      # overridden to render footnotes in an actual footer element
      def footnote_content
        ol = ::Kramdown::Element.new(:ol)
        ol.attr['start'] = @footnote_start if @footnote_start != 1
        i = 0
        backlink_text = escape_html(@options[:footnote_backlink], :text)
        while i < @footnotes.length
          name, data, _, repeat = *@footnotes[i]
          li = ::Kramdown::Element.new(:li, nil, {'id' => "fn:#{name}"})
          li.children = Marshal.load(Marshal.dump(data.children))

          if li.children.last.type == :p
            para = li.children.last
            insert_space = true
          else
            li.children << (para = ::Kramdown::Element.new(:p))
            insert_space = false
          end

          unless @options[:footnote_backlink].empty?
            para.children << ::Kramdown::Element.new(:raw, FOOTNOTE_BACKLINK_FMT % [insert_space ? ' ' : '', name, backlink_text])
            (1..repeat).each do |index|
              para.children << ::Kramdown::Element.new(:raw, FOOTNOTE_BACKLINK_FMT % [" ", "#{name}:#{index}", "#{backlink_text}<sup>#{index+1}</sup>"])
            end
          end

          ol.children << ::Kramdown::Element.new(:raw, convert(li, 4))
          i += 1
        end
        (ol.children.empty? ? '' : format_as_indented_block_html('footer', {:class => "footnotes"}, convert(ol, 2), 0))
      end

      private

      def render_figure_img(el, indent)
        attr = el.attr.dup
        caption = extract_caption_from_attrs! attr
        "#{' '*indent}<figure class=\"image\">#{convert_img el, 0}#{caption}</figure>\n"
      end

      def extract_caption_from_attrs!(attr)
        if title = attr.delete('title')
          "<figcaption>#{title}</figcaption>"
        end
      end

      def image_path(asset, size = nil)
        if Bold::Kramdown::preview_mode?
          asset.preview_path
        else
          asset.public_path(size)
        end
      end

    end

  end
end