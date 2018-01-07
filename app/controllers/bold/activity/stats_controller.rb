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
module Bold::Activity
  class StatsController < SiteController

    def index
      @stats = Bold::Stats::Ahoy.for time_frame: time_frame_param, site: current_site
    end

    def visits_per_day
      render json: Bold::Stats::Ahoy.for(site: current_site,
                                         time_frame: time_frame_param).daily_visits.data
    end

    private

    def time_frame_param
      (params[:time_frame].presence || :month).to_sym
    end
  end
end
