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

    def self.setup
      FiguresExtension.setup
      ::Kramdown::Parser::Kramdown.prepend DisableOptionsExtension
    end

    def preview_mode?
      !!RequestStore.store[:preview_mode]
    end
    module_function :preview_mode?

    def preview_mode!
      RequestStore.store[:preview_mode] = true
    end
    module_function :preview_mode!


    MARKDOWN_OPTIONS = {
      auto_id_stripping: true,
      auto_ids: true,
      enable_coderay: true,    # site setting?
      entity_output: :as_char,
      hard_wrap: true,
      header_offset: 0,        # site setting?
      parse_block_html: true, # site setting?
      parse_span_html: true,
      remove_block_html_tags: false,
      remove_span_html_tags: false,
      syntax_highlighter_opts: {
        span: {
          css: :class,
          line_numbers: nil,
          tab_width: 2,
          wrap: nil,
        },
        block: {
          css: :class,
          line_numbers: nil, # setting?
          tab_width: 2,
          wrap: nil,
        },
        default_lang: nil,
      },
      toc_levels: (1..4).to_a,  # https://github.com/gettalong/kramdown/pull/210
      transliterated_header_ids: true
    }

    # remove all the fancy stuff for rendering of external input (comments)
    SAFE_MARKDOWN_OPTIONS = MARKDOWN_OPTIONS.merge(
      input: 'markdown',
      auto_ids: false,
      math_engine: nil,
      enable_coderay: false,
      header_offset: 3,
      parse_block_html: false,
      parse_span_html: false,
      remove_block_html_tags: true,
      remove_span_html_tags: true,
      syntax_highlighter: nil,
      transliterated_header_ids: false,
      link_attributes: { rel: 'nofollow' }
    )

    def to_html(text, trusted = false, options = {})
      text = text.to_s
      text = ERB::Util.html_escape_once(text) unless trusted
      opts = markdown_options(trusted).update options
      doc = ::Kramdown::Document.new text, opts
      output, warnings = HtmlConverter.convert(doc.root, opts)
      Rails.logger.warn warnings
      output
    end

    def markdown_options(trusted = false)
      trusted ? MARKDOWN_OPTIONS : SAFE_MARKDOWN_OPTIONS
    end

  end
end