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
    Bold::current_site = @site = create :site
    @page = publish_page template: 'contact_page'
  end

  test 'should take site from contact_page' do
    co = create :contact_message, content: @page
    assert_equal @page.site, co.site
  end

  test 'should be pending by default' do
    co = create :contact_message, content: @page
    assert co.pending?
  end



end
