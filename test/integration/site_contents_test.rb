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

class SiteContentsTest < BoldIntegrationTest

  setup do
    @site.update_attributes site_css: "site css", site_js: "site js"
  end

  test 'should render site js' do
    visit '/site.js'
    assert has_content? 'site js'
  end

  test 'should render site css' do
    visit '/site.css'
    assert has_content? 'site css'
  end

  test 'should raise error for unknown formats' do
    assert_raise(ActionController::UnknownFormat){ visit '/site.txt' }
  end

end


