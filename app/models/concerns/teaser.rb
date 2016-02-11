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
module Teaser
  extend ActiveSupport::Concern
  include Markdown

  # if you change this marker, also change bold/admin/editor.js.coffee
  BREAK_MARKER = '<!-- break -->'
  BREAK_RE = /\A(?<teaser>.*)#{BREAK_MARKER}/m

  def teaser_html(words = 0)
    md_render_content self, teaser_text(words)
  end

  def teaser_text(words = 0)
    words = words.to_i
    if teaser.present?
      teaser
    elsif text_before_break.present?
      text_before_break
    end
  end

  def has_teaser?
    teaser.present? || text_before_break.present?
  end

  private

  def text_before_break
    if false != @text_before_break
      @text_before_break = if match = BREAK_RE.match(body)
                             match[:teaser]
                           else
                             false
                           end
    else
      nil
    end
    @text_before_break
  end

end