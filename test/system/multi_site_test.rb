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

# append "bold.local site2.local" to the line starting with 127.0.0.1 in /etc/hosts
class MultiSiteTest < ApplicationSystemTestCase

  setup do
    create_homepage
    publish_post title: 'hello from site 1', body: 'lorem ipsum'

    @site2 = create :site, hostname: 'site2.local', name: 'Seite zwei'
    @site2.add_user! @user
    create_homepage site: @site2
    publish_post title: 'hello from site 2', body: 'lorem ipsum', site: @site2
  end

  test 'should detect site by hostname' do
    visit '/'
    assert_text 'hello from site 1'
    Capybara.app_host = "http://site2.local/"
    visit '/'
    assert_text 'hello from site 2'
  end

  test 'should redirect to admin for backend host name' do
    Capybara.app_host = 'http://bold.local'
    visit '/'
    assert_equal '/users/sign_in', current_path
  end

  test 'should render 404 for unknown host name' do
    @site2.destroy
    Capybara.app_host = 'http://site2.local'
    visit '/'
    assert_text 'Page not found'
  end

  test 'should select a site' do
    visit '/bold'
    assert_equal '/users/sign_in', current_path
    fill_in 'Email address', with: @user.email
    fill_in 'Password', with: 'secret.1'
    click_button 'Sign in'
    assert_equal '/bold', current_path
    first(:link, @site2.name).click
    assert_equal "/bold/sites/#{@site2.id}", current_path
    click_on 'Posts'
    assert_text 'hello from site 2'
    refute_text 'hello from site 1'
  end

  test 'backend should show site selector for signed in user and unknown host name' do
    @site2.update_attribute :hostname, 'other.local'
    Capybara.app_host = 'http://site2.local'
    visit '/users/sign_in'
    assert_text('Sign in')
    fill_in 'Email address', with: @user.email
    fill_in 'Password', with: 'secret.1'
    click_button 'Sign in'
    assert !has_content?('Sign in')
    assert_equal '/bold', current_path
    assert_text 'Select a site'
  end

end
