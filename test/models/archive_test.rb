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

class ArchiveTest < ActiveSupport::TestCase
  setup do
    Bold::current_site = @site = create :site
    create :published_post, site: @site, post_date: Time.local(2013, 9, 2)
    create :published_post, site: @site, post_date: Time.local(2015, 6, 29)

    @archive = Bold::Archive.new site: @site
  end

  test 'should get years' do
    assert years = @archive.years
    assert_equal [[2015, 1], [2014, 0], [2013, 1]], years
  end

  test 'should get months' do
    assert months = @archive.months
    assert_equal [[2015, 6, 1], [2013, 9, 1]], months
  end
end
