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

class Stats
  include ActiveModel::Model

  attr_reader :end_date, :start_date, :time_frame, :time_frame_length

  TIME_FRAMES = {
    month: 4.weeks,
    quarter: 12.weeks,
    year: 1.year
  }

  def initialize(site: Site.current,
                 time_frame: :month,
                 end_date: site.time_zone.yesterday,
                 start_date: nil)
    @site = site
    @time_frame = TIME_FRAMES.key?(time_frame) ? time_frame : :month
    @time_frame_length = TIME_FRAMES[@time_frame]
    @end_date   = end_date
    @start_date = start_date || (@end_date - length + 1)
  end

  def daily_pageviews
    @daily_pageviews ||= Bold::Stats::Metrics::DailyPageviews.new(
      from: @start_date,
      to: @end_date,
      site: @site
    )
  end

  def daily_visits
    @daily_visits ||= Bold::Stats::Metrics::DailyVisits.new(
      from: @start_date,
      to: @end_date,
      site: @site
    )
  end

  def length
    time_frame_length / 1.day
  end


end