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

class StatsVisitTest < ActiveSupport::TestCase
  setup do
    Bold::current_site = @site = create :site
  end

  test 'should decide wether to add to an existing visit or start a new one' do
    v = create :stats_visit, ended_at: 40.minutes.ago
    assert !v.can_include?(Time.now)
    assert v.can_include?(20.minutes.ago)
  end

  test 'should create from request log' do
    log = create :request_log, created_at: 5.minutes.ago
    log.reload
    assert log.visitor_id.present?

    assert v = StatsVisit.find_or_create_for_log(log)
    assert_equal log.created_at, v.started_at
    assert_equal log.created_at, v.ended_at
    assert_equal log.created_at.to_date, v.date

    log2 = create :request_log, visitor_id: log.visitor_id, created_at: 1.minute.ago
    assert v2 = StatsVisit.find_or_create_for_log(log2)
    assert_equal v, v2
    assert_equal log2.created_at, v2.ended_at


  end

end
