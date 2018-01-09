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
    v = create :visit, started_at: 12.days.ago, site_id: @site.id
    create :ahoy_event, time: 12.days.ago, visit: v,
      properties: { page: @page.id }
    v = create :visit, started_at: 8.days.ago, site_id: @site.id
    create :ahoy_event, time: 8.days.ago, visit: v,
      properties: { page: @post.id }

    v = create :visit, started_at: day_0.beginning_of_day + 1.hours, site_id: @site.id
    @v0_1  = create :ahoy_event, time: day_0.beginning_of_day + 1.hours, visit: v,
      properties: { page: @page.id }
    v = create :visit, started_at: day_0.beginning_of_day + 8.hours, site_id: @site.id
    @v1_1  = create :ahoy_event, time: day_0.beginning_of_day + 8.hours, visit: v,
      properties: { page: @page.id }

    @v1_1a = create :ahoy_event, time: day_0.beginning_of_day + 8.hours + 5.minutes,
                                  visit: @v1_1.visit,
                                  properties: { page: @page.id }
    @v1_2  = create :ahoy_event, time: day_0.beginning_of_day + 8.hours + 6.minutes,
                                  visit: @v1_1.visit,
                                  properties: { page: @post.id }


    # same time and page, different visitor
    v = create :visit, started_at: day_2.beginning_of_day + 1.hour, site_id: @site.id
    @v2 = create :ahoy_event, time: day_2.beginning_of_day + 1.hour, visit: v,
      properties: { page: @page.id }
    @v3 = create :ahoy_event, time: day_2.beginning_of_day + 1.hour,
                               visit: @v1_1.visit,
                               properties: { page: @page.id }

    v = create :visit, started_at: day_4, site_id: @site.id
    @v4 = create :ahoy_event, time: day_4, visit: v,
      properties: { page: @page.id }

    # two pageviews by same visitor, same page but different visits
    v = create :visit, started_at: day_5.beginning_of_day + 9.hours, site_id: @site.id
    @v5 = create :ahoy_event, visit: v, time: day_5.beginning_of_day + 9.hours,
      properties: { page: @page.id }
    v = create :visit, started_at: day_5.beginning_of_day + 17.hours, site_id: @site.id
    @v6 = create :ahoy_event, time: day_5.beginning_of_day + 17.hours,
                               visit: v,
                               properties: { page: @page.id }

  end

  test 'should get pageviews data' do
    stats = Bold::Stats::Ahoy::DailyPageViews.new(from: 7.days.ago, to: Time.now, site: @site).compute
    assert data = stats.data
    assert_equal 6, data.length
    assert_equal [4, 0, 2, 0, 1, 2], data.values
  end

  test 'should get average pageviews' do
    stats = Bold::Stats::Ahoy::DailyPageViews.new(from: 7.days.ago, to: Time.now, site: @site).compute
    assert_equal 1.5, stats.avg
  end

  test 'should get visits data' do
    stats = Bold::Stats::Ahoy::DailyVisits.new(from: 7.days.ago, to: Time.now, site: @site).compute
    assert data = stats.data
    assert_equal 6, data.length
    assert_equal [2, 0, 1, 0, 1, 2], data.values
  end

  test 'should get previous visits average' do
    stats = Bold::Stats::Ahoy::DailyVisits.new(from: 7.days.ago, to: Time.now, site: @site).compute
    assert_equal 0.4, stats.prev_avg
  end

  test 'should get average visits' do
    stats = Bold::Stats::Ahoy::DailyVisits.new(from: 7.days.ago, to: Time.now, site: @site).compute
    assert_equal 1, stats.avg
  end

  test 'should get pageviews per visit' do
    stats = Bold::Stats::Ahoy::PageViewsPerVisit.new(from: 7.days.ago, to: Time.now, site: @site).compute
    assert_equal 1.4, stats.avg
  end

  test 'should get previous average visits' do
    stats = Bold::Stats::Ahoy::DailyVisits.new(from: 7.days.ago, to: Time.now, site: @site).compute
    assert_equal 0.4, stats.prev_avg
  end

end
