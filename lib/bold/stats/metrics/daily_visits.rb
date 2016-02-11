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

      # visits per day
      #
      # the maximum inactivity (gap between pageviews) is 30 minutes. visitors
      # are recognized by cookie-stored id.
      class DailyVisits < DailyCount
        def scope
          @site.stats_visits
        end

        def pageviews_per_visit
          return 0.0 if records_in_range.blank?
          (records_in_range.average(:length) * 100).round / 100.to_f
        end

        def pageviews_per_visit_delta
          pageviews_per_visit - previous.pageviews_per_visit
        end
      end

    end
  end
end