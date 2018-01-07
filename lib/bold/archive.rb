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
  class Archive

    attr_reader :month, :year

    def initialize(site: Site.current, year: nil, month: nil)
      @site = site
      @year = year.to_i if year
      @month = month.to_i if month
    end

    # returns an array of [year, post_count] pairs
    def years
      posts = @site.posts.published.order('post_date DESC').pluck(:post_date)
      @years ||= if posts.any?
        posts.first.year.downto(posts.last.year).to_a.map do |y|
          [ y, _posts(y).count ]
        end
      else
        [[ Time.zone.now.year, 0 ]]
      end
    end

    # returns an array of [year, month, post_count] triplets
    def months
      @months ||= years.map do |y, count|
        _posts(y).pluck(:post_date).to_a.map(&:month).uniq.map do |m|
          [ y, m, _posts(y, m).count ]
        end
      end.flatten 1
    end

    def to_date
      Time.zone.local(@year, @month || 1, 1).to_date if @year
    end

    def posts(limit: 50, page: 1)
      ::ContentsDecorator.decorate(
        _posts(@year, @month).page(page).per(limit)
      )
    end

    def _posts(year = nil, month = nil)
      scope = @site.posts.published.ordered
      if month.present?
        scope = scope.for_month(year.to_i, month.to_i)
      elsif year.present?
        scope = scope.for_year(year.to_i)
      end
      scope
    end


  end
end
