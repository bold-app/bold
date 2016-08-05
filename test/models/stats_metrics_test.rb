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

class StatsMetricsTest < ActiveSupport::TestCase

  setup do
    Time.zone = 'UTC'
    Bold::current_site = @site = create :site, time_zone_name: 'UTC'

    @page = create :page
    @page_link = create :permalink, path: @page.slug, destination: @page
    @post = create :post
    @post_link = create :permalink, path: @post.slug, destination: @post
    today = Time.zone.today
    day_0 = today - 6
    day_2 = today - 4
    day_4 = today - 2
    day_5 = today - 1

    # these dont count
    create :request_log, created_at: 12.days.ago,
                         resource: @page,
                         permalink: @page.permalink
    create :request_log, created_at: 8.days.ago,
                         resource: @post,
                         permalink: @post.permalink

    @v0_1  = create :request_log, created_at: day_0.beginning_of_day + 1.hours,
                                  resource: @page,
                                  permalink: @page.permalink
    @v1_1  = create :request_log, created_at: day_0.beginning_of_day + 8.hours,
                                  resource: @page,
                                  permalink: @page.permalink

    @v1_1a = create :request_log, created_at: day_0.beginning_of_day + 8.hours + 5.minutes,
                                  visitor_id: @v1_1.visitor_id,
                                  resource: @page,
                                  permalink: @page.permalink
    @v1_2  = create :request_log, created_at: day_0.beginning_of_day + 8.hours + 6.minutes,
                                  visitor_id: @v1_1.visitor_id,
                                  resource: @post,
                                  permalink: @post.permalink


    # same time and page, different visitor
    @v2 = create :request_log, created_at: day_2.beginning_of_day + 1.hour,
                               resource: @page,
                               permalink: @page.permalink
    @v3 = create :request_log, created_at: day_2.beginning_of_day + 1.hour,
                               visitor_id: @v1_1.visitor_id,
                               resource: @page,
                               permalink: @page.permalink

    @v4 = create :request_log, created_at: day_4,
                               resource: @page,
                               permalink: @page.permalink

    # two pageviews by same visitor, same page but different visits
    @v5 = create :request_log, created_at: day_5.beginning_of_day + 9.hours,
                               resource: @page,
                               permalink: @page.permalink
    @v6 = create :request_log, created_at: day_5.beginning_of_day + 10.hours,
                               visitor_id: @v5.visitor_id,
                               resource: @page,
                               permalink: @page.permalink

    StatsPageview.build_pageviews @site
  end

  test 'should get pageviews data' do
    stats = Bold::Stats::Metrics::DailyPageviews.new from: 6.days.ago
    assert data = stats.data
    assert_equal 7, data.length
    days, counters = data.transpose
    assert_equal [4, 0, 2, 0, 1, 2, 0], counters
  end

  test 'should get average pageviews' do
    stats = Bold::Stats::Metrics::DailyPageviews.new from: 6.days.ago
    assert_equal 1.29, stats.avg
  end

  test 'should get unique pageviews data' do
    stats = Bold::Stats::Metrics::DailyUniquePageviews.new from: 6.days.ago
    assert data = stats.data
    assert_equal 7, data.length
    days, counters = data.transpose
    assert_equal [3, 0, 2, 0, 1, 2, 0], counters
  end

  test 'should get average unique pageviews' do
    stats = Bold::Stats::Metrics::DailyUniquePageviews.new from: 6.days.ago
    assert_equal 1.14, stats.avg
  end

  test 'should get visits data' do
    stats = Bold::Stats::Metrics::DailyVisits.new from: 6.days.ago
    assert data = stats.data
    assert_equal 7, data.length
    days, counters = data.transpose
    assert_equal [2, 0, 2, 0, 1, 2, 0], counters
  end

  test 'should get previous visits data' do
    stats = Bold::Stats::Metrics::DailyVisits.new from: 6.days.ago
    prev = stats.previous
    assert data = prev.data
    assert_equal 7, data.length
    days, counters = data.transpose
    assert_equal [0, 1, 0, 0, 0, 1, 0], counters
  end

  test 'should get average visits' do
    stats = Bold::Stats::Metrics::DailyVisits.new from: 6.days.ago
    assert_equal 1, stats.avg
  end

  test 'should get pageviews per visit' do
    stats = Bold::Stats::Metrics::DailyVisits.new from: 6.days.ago
    assert_equal 1.29, stats.pageviews_per_visit
  end

  test 'should get previous average visits' do
    stats = Bold::Stats::Metrics::DailyVisits.new from: 6.days.ago
    prev = stats.previous
    assert_equal 0.29, prev.avg
  end

end
