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

class SetupTest < BoldIntegrationTest

  setup do
    Site.destroy_all
    User.destroy_all
  end

  test 'root should render 404 when no sites' do
    visit '/'
    assert has_content? 'Page not found'
  end


  test 'setup process' do
    visit '/bold'
    assert_equal '/setup/user/new', current_path
    email = Faker::Internet.email
    fill_in 'Name', with: Faker::Name.name
    fill_in 'Email address', with: email
    pwd = Faker::Internet.password(8, 20)
    fill_in 'Password', with: pwd
    fill_in 'Confirm your new password', with: pwd
    assert_difference 'User.count' do
      click_on 'Continue'
    end
    select 'Test Theme', from: 'Theme'
    fill_in 'Site name', with: 'Test site'
    fill_in 'Hostname', with: 'example.com'
    assert_difference 'Site.count' do
      click_on 'Continue'
    end
    assert site = Site.first
    assert_equal 'test', site.theme_name
    assert site.homepage.present?
    assert_equal 'homepage', site.homepage.template

    assert u = site.users.first
    assert_equal email, u.email
  end

end