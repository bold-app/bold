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

class MultiSiteTest < BoldIntegrationTest

  setup do
    @user = create :confirmed_user
    @site1 = create :site, hostname: 'site1.de', name: 'Site one'
    create_homepage site: @site1
    publish_post title: 'hello from site 1', body: 'lorem ipsum', site: @site1

    @site2 = create :site, hostname: 'site2.de', name: 'Seite zwei'
    create_homepage site: @site2
    publish_post title: 'hello from site 2', body: 'lorem ipsum', site: @site2
    [@site1, @site2].each{|s| s.add_user! @user}
  end

  test 'should detect site by hostname' do
    set_host 'site2.de'
    visit '/'
    assert has_content? 'hello from site 2'
    set_host 'site1.de'
    assert_difference '@site1.homepage.request_logs.count' do
      assert_difference '@site1.request_logs.count' do
        visit '/'
      end
    end
    assert has_content? 'hello from site 1'

  end

  test 'should redirect to admin for backend host name' do
    set_host 'bold.local'
    visit '/'
    assert_equal '/users/sign_in', current_path
  end

  test 'should render 404 for unknown host name' do
    set_host 'foo.bar'
    visit '/'
    assert has_content? 'Page not found'
  end

  test 'should select a site' do
    set_host 'cms.site1.de'
    visit '/bold'
    assert_equal '/users/sign_in', current_path
    fill_in 'Email address', with: @user.email
    fill_in 'Password', with: 'secret.1'
    click_button 'Sign in'
    assert_equal '/bold', current_path
    first(:link, @site2.name).click
    assert_equal "/bold/sites/#{@site2.id}", current_path
    click_on 'Posts'
    assert  has_content?  'hello from site 2'
    assert  !has_content?('hello from site 1')
  end

  test 'backend should show site selector for signed in user and unknown host name' do
    set_host 'cms.site1.de'
    visit '/users/sign_in'
    assert has_content?('Sign in')
    fill_in 'Email address', with: @user.email
    fill_in 'Password', with: 'secret.1'
    click_button 'Sign in'
    assert !has_content?('Sign in')
    assert_equal '/bold', current_path
    assert has_content? 'Select a site'
  end

end
