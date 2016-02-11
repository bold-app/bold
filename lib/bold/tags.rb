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
  class Tags
    def initialize(site)
      @site = site
    end

    # segments tags in _groups_ groups of roughly the same size, so the first
    # group has the least used tags, and the last those used most often.
    # returns an array of [tag, group_index] pairs with group_index ranging
    # from 1 to _groups_.
    def grouped_tags(groups = 4)
      tags = @site.tags.where('taggings_count > 0')
      tag_count = tags.count
      group_size = tag_count / groups.to_f
      [].tap do |result|
        tags.order('taggings_count ASC, lower(name) ASC').to_a.each_with_index do |tag, idx|
          group = ((idx+1)/group_size).ceil
          group = groups if group > groups
          result << [tag.decorate, group]
        end
      end
    end

    def each(&block)
      grouped_tags.each &block
    end
  end
end