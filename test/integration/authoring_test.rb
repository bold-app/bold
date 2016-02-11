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

class AuthoringTest < BoldIntegrationTest

  setup do
    @user = create :confirmed_user
    @site1 = create :site, hostname: 'site1.de', name: 'Site one'
  end

  test 'new post' do
    set_host 'site1.de'
    login_as @user
    visit '/bold/posts/new'
  end

  test 'page template change' do
    set_host 'site1.de'
    login_as @user
    visit '/bold/pages'
    within '.left-col header' do
      click_link 'new-page'
    end

  end

end