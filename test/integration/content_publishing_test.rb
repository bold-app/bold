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

class ContentPublishingTest < BoldIntegrationTest

  setup do
    @page = save_page slug: 'some-page', title: 'hello from site 1', body: 'some page'
  end

  test 'should not navigate to unpublished page' do
    visit '/some-page'
    assert_equal 404, status_code
    assert has_content? 'not found'

    SaveContent.call @page, publish: true
    visit '/some-page'
    assert has_content? 'hello from site 1'
    assert has_content? 'some page'

    @page.unpublish
    @page.save
    visit '/some-page'
    assert_equal 404, status_code
    assert has_content? 'not found'
  end

end


