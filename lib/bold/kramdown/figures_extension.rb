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

    # Extends Kramdown with a definition-list like syntax for figures (that is,
    # images with a caption).
    # Inspired by https://github.com/helderco/markdown-figures .
    #
    module FiguresExtension

      def self.setup
        ::Kramdown::Parser::Kramdown.prepend Parser
        ::Kramdown::Parser::Kramdown.define_parser(
          :figure,
          ::Kramdown::Parser::Kramdown::DEFINITION_LIST_START
        )
        ::Kramdown::Converter::Html.prepend HtmlConverter
      end

      module HtmlConverter
        def convert_figure(el, indent)
          if img = el.children.first
            slug, size, link_to = img.attr['src'].to_s.split('!')
            (el.attr['class'] ||= '') << ' image'
            el.attr['class'] << ' ' << size if size
            el.attr['class'].strip!
          end
          format_as_indented_block_html el.type, el.attr, "#{' '*(indent+@indent)}#{inner(el, indent)}", indent
        end
        def convert_figcaption(el, indent)
          "\n#{format_as_indented_block_html el.type, el.attr, inner(el, indent), indent}"
        end
      end

      module Parser

        def initialize(*args)
          super
          @block_parsers.unshift :figure
        end

        IMG_START = /!\[(?=[^^])/
        def parse_figure
          children = @tree.children
          if para = children.last
            element = para.children.first.try(:value).to_s
            if element =~ IMG_START
              first_as_para = false
              para = children.pop
              if para.type == :blank
                para = children.pop
                first_as_para = true
              end
              figure = new_block_el :figure, location: para.options[:location]
              figure.children << ::Kramdown::Element.new(:raw_text, element)
              figure.options[:ial] = para.options[:ial]

              caption = nil
              content_re, lazy_re, indent_re = nil
              def_start_re = ::Kramdown::Parser::Kramdown::DEFINITION_LIST_START
              last_is_blank = false
              while !@src.eos?
                start_line_number = @src.current_line_number
                if @src.scan(def_start_re)
                  caption = new_block_el :figcaption, nil, nil, location: start_line_number
                  caption.options[:first_as_para] = first_as_para
                  caption.value, indentation, content_re, lazy_re, indent_re = parse_first_list_line(@src[1].length, @src[2])
                  figure.children << caption

                  def_start_re = /^( {0,#{[3, indentation - 1].min}}:)([\t| ].*?\n)/
                  last_is_blank = false
                elsif @src.check(::Kramdown::Parser::Kramdown::EOB_MARKER)
                  break
                elsif (result = @src.scan(content_re)) || (!last_is_blank && (result = @src.scan(lazy_re)))
                  result.sub!(/^(\t+)/) { " "*($1 ? 4*$1.length : 0) }
                  result.sub!(indent_re, '')
                  caption.value << result
                  last_is_blank = false
                else
                  break
                end
              end

              if caption
                parse_blocks(caption, caption.value)
                caption.value = nil
              end

              @tree.children << figure
              return true
            end
          end
          false
        end
      end

    end
  end
end