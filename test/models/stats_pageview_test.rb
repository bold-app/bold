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

class StatsPageviewTest < ActiveSupport::TestCase

  setup do
    Bold::current_site = @site = create :site
    @page = create :page
    @page_link = create :permalink, destination: @page
  end

  test 'should build from request log' do
    log = create :request_log, created_at: 5.minutes.ago,
                               resource: @page,
                               permalink: @page_link
    assert pv = StatsPageview.build_for_log(log)
    assert pv.save, pv.errors.inspect
    assert_equal log, pv.request_log
    assert pv.stats_visit
    assert_equal log.created_at.to_date, pv.date
    assert_equal log.resource, pv.content
    assert_equal 1, pv.stats_visit.length
  end

  test 'should build pageviews for all unprocessed request logs' do
    create :request_log, created_at: 50.minutes.ago,
                         processed: true,
                         resource: @page,
                         permalink: @page_link
    create :bot_request, created_at: 50.minutes.ago,
                         resource: @page,
                         permalink: @page_link
    create :mobile_request, created_at: 1.hour.ago,
                            resource: @page,
                            permalink: @page_link
    create :request_log, created_at: 5.minutes.ago,
                         resource: @page,
                         permalink: @page_link
    create :request_log, created_at: 5.minutes.ago,
                         resource: @page,
                         permalink: @page_link

    assert_difference 'StatsPageview.count', 3 do
      StatsPageview.build_pageviews @site
    end

    assert_equal 0, RequestLog.where(processed: false).count
  end
end
