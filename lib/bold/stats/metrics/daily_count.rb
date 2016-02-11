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

      class DailyCount < Base
        # date / number pairs for each day
        def data
          @data ||= compute
        end

        def compute
          values_by_day = records_in_range.group(:date).count(count_by)
          compute_dates.map do |date|
            [ date, values_by_day[date] || 0 ]
          end
        end

        def records_in_range
          scope.since(@from).until(@to)
        end

        # average daily value
        def avg
          values = data.transpose.last
          return 0.0 if values.blank?
          (values.sum.to_f / values.length * 100).round / 100.to_f
        end

        # change compared to previous period average
        def delta
          avg - previous.avg
        end

        private

        def scope
          raise 'implement me!'
        end

        def count_by
          nil
        end
      end

    end
  end
end