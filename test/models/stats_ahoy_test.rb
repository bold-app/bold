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
require 'test_helper'

class StatsAhoyTest < ActiveSupport::TestCase

  setup do
    Bold::current_site = @site = create :site, time_zone_name: 'UTC'
  end

  test 'should calculate dates from time_frame' do
    stats = Bold::Stats::Ahoy.for time_frame: :month, site: @site
    assert_equal 28, ((stats.to - stats.from) / 1.day).round
    assert_equal @site.time_zone.yesterday, stats.to_date
    assert_equal @site.time_zone.yesterday - 27.days, stats.from_date
  end

end
