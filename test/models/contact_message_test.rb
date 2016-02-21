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

class ContactMessageTest < ActiveSupport::TestCase
  setup do
    @site = create :site
    @page = create :published_page, site: @site, template: 'contact_page'
  end

  test 'should take site from contact_page' do
    co = create :contact_message, content: @page
    assert_equal @page.site, co.site
  end

  test 'should be pending by default' do
    co = create :contact_message, content: @page
    assert co.pending?
  end

  test 'mark spam should mark deleted and enqueue job' do
    co = create :contact_message, content: @page
    assert_no_difference 'ContactMessage.count' do
      assert_difference 'ContactMessage.alive.count', -1 do
        assert_enqueued_with(job: AkismetUpdateJob) do
          co.mark_as_spam!
        end
      end
    end
  end

  test 'mark ham should change status and enqueue job' do
    co = create :contact_message, content: @page
    co.spam!
    assert_enqueued_with(job: AkismetUpdateJob) do
      co.mark_as_ham!
    end
    co.reload
    assert co.pending?
  end

end
