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
class Page < Content
  after_initialize :set_default_values

  def path
    super || (
      '' if homepage?
    )
  end

  def fulltext_searchable?
    super && !site.special_page_ids.include?(id)
  end

  private

  def permalink_path_args
    # only generate a permalink for published pages
    [ slug ] if published?
  end

  def set_default_values
    if new_record? && site
      self.template ||= site.theme_config.default_page_template
    end
  end
end