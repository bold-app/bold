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
require 'application_system_test_case'

class AuthoringTest < ApplicationSystemTestCase

  test 'new post' do
    login_as @user
    click_link 'Posts'
    within '.left-col header' do
      click_link 'new-post'
    end
    assert_equal "/bold/sites/#{@site.id}/posts/new", current_path
  end

  test 'page template change' do
    login_as @user
    click_link 'Pages'
    within '.left-col header' do
      click_link 'new-page'
    end

  end

end