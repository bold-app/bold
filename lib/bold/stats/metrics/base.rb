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
  module Stats
    module Metrics

      class Base
        attr_reader :from, :to

        def initialize(to: Time.zone.today,
                       from: (to - 4.weeks),
                       site: Site.current)
          @site = site
          @from = to_date from
          @to   = to_date to
          if length <= 0
            raise ArgumentError, 'end date cannot be equal or less than start date'
          end
        end

        def length
          (@to - @from).to_i
        end

        def previous
          previous_to = @from - 1
          self.class.new to: previous_to, from: previous_to - length, site: @site
        end

        def compute_dates
          from.upto(to).to_a
        end

        private

        def to_date(date_or_time)
          if date_or_time.respond_to?(:to_date)
            # beginning_of_day is critical because otherwise we might end up
            # with Date instances that have a non-zero day_fraction set, which
            # leads to misses when using these to access the hash returned by
            # ActiveRecord when grouping by :date
            date_or_time.beginning_of_day.to_date
          else
            date_or_time
          end
        end
      end

    end
  end
end
