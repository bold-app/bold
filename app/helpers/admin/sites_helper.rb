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
module Admin
  module SitesHelper
    def all_themes
      Bold::Theme.all.values.sort do |a, b|
        a.name.unicode_downcase <=> b.name.unicode_downcase
      end
    end

    def comment_options
      Site::COMMENTABLE_STATES.map do |o|
        [ o, t("bold.admin.sites.edit.comments.#{o}") ]
      end
    end
  end
end
