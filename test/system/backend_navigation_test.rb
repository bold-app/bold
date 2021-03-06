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

class BackendNavigationTest < ApplicationSystemTestCase

  test 'should require sign in' do
    visit "/bold"
    assert_equal '/users/sign_in', current_path
  end

  test 'logout should log out' do
    login_as @user
    visit '/bold'
    assert has_link? @site.name
    logout
    assert_equal '/users/sign_in', current_path
  end

  test 'should hide settings from editor' do
    login_as @user
    within '.navbar' do
      assert_text 'Pages'
      assert_text 'Posts'
      refute_text('Settings')
      assert_text @site.name
    end
    click_on 'Pages'
    assert_equal "/bold/sites/#{@site.id}/pages", current_path
    click_on 'Posts'
    assert_equal "/bold/sites/#{@site.id}/posts", current_path

    visit "/bold/sites/#{@site.id}/settings"
    assert_equal '/users/sign_in', current_path
  end

  test 'should show all menu items to site admin' do
    login_as @site_admin
    within '.navbar' do
      assert_text 'Pages'
      assert_text 'Posts'
      assert_text 'Settings'
      assert_text @site.name
      #assert has_link? 'Sign out' hidden behind profile pic / can we simulate
      #hover?
    end
    click_on 'Pages'
    assert_equal "/bold/sites/#{@site.id}/pages", current_path
    click_on 'Posts'
    assert_equal "/bold/sites/#{@site.id}/posts", current_path
    click_on 'Settings'
    assert_equal "/bold/sites/#{@site.id}/settings", current_path
  end

end
