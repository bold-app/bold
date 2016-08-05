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

class StatsTest < ActiveSupport::TestCase

  setup do
    Bold::current_site = @site = create :site, time_zone_name: 'UTC'
    @page = create :page
    @page_link = create :permalink, destination: @page
    @post = create :post
    @post_link = create :permalink, destination: @post, path: 'some/post'
    @sunday = DateTime.parse('2015-09-27 23:45 UTC')
    @monday = DateTime.parse('2015-09-28 00:15 UTC')
    @friday = DateTime.parse('2015-10-02 13:00 UTC')
    @r1 = create :request_log, created_at: @sunday,
                               resource: @page,
                               permalink: @page_link
    @r2 = create :request_log, created_at: @monday, visitor_id: @r1.visitor_id,
                               resource: @page,
                               permalink: @page_link
    @r2 = create :request_log, created_at: @monday+1.second, visitor_id: @r1.visitor_id, resource: @post, permalink: @post_link
    @r3 = create :request_log, created_at: @monday,
                               resource: @page,
                               permalink: @page_link
    @r4 = create :request_log, created_at: @friday,
                               resource: @page,
                               permalink: @page_link
  end

  test 'should have dates and length' do
    stats = Stats.new time_frame: :month
    assert_equal :month, stats.time_frame
    assert_equal 28, stats.length
    assert_equal @site.time_zone.yesterday, stats.end_date
    assert_equal @site.time_zone.yesterday - 27.days, stats.start_date
  end

  test 'should count page views' do
    StatsPageview.build_pageviews @site
    stats = Stats.new time_frame: :month, end_date: @friday.to_date
    assert data = stats.daily_pageviews.data
    assert_equal 28, data.length

    dates, pageviews = data.transpose
    assert_equal ([0]*21)+[0, 1, 3, 0, 0, 0, 1 ], pageviews
  end

  test 'should count visitors' do
    StatsPageview.build_pageviews @site
    stats = Stats.new time_frame: :quarter, end_date: @friday.to_date
    assert data = stats.daily_visits.data
    assert_equal 12*7, data.length

    dates, visits = data.transpose
    assert_equal 1, visits.last
  end

end
