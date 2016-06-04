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

    # returns an array of [tag, group_index] pairs.
    #
    # Lower group index means more frequently used tag, starting with 0.
    def weighted_tags(*args)
      result = []
      grouped_tags(*args).each_with_index do |tags, index|
        result << tags.compact.map{|t| [t, index]}
      end
      return result.flatten(1)
    end

    # segments tags in _groups_ groups of roughly the same size, so the first
    # group has the most used tags, and the last those used the least.
    # returns an array of arrays, holding decorated tags.
    #
    # There may be less groups returned than requested, but it will never be
    # more.
    def grouped_tags(groups: 4, limit: nil)
      tags = @site.tags.where('taggings_count > 0')
      tags = tags.limit(limit.to_i) if limit
      tag_count = tags.count
      groups = groups.to_i
      groups = tag_count if groups > tag_count
      group_size = (tag_count / groups.to_f).ceil

      tags.
        order('taggings_count DESC, lower(name) ASC').
        map(&:decorate).
        in_groups_of(group_size)
    end

  end
end
