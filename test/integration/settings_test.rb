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

class SettingsTest < BoldIntegrationTest

  setup do
  end

  teardown do
  end

  test 'should require sign in' do
    visit "/bold/sites/#{@site.id}/settings"
    assert_equal '/users/sign_in', current_path
  end

  test 'should not allow access for editor' do
    login_as @user
    visit "/bold/sites/#{@site.id}/settings"
    assert_equal '/users/sign_in', current_path
  end

  test 'should allow editing of site settings' do
    login_as @site_admin
    visit "/bold/sites/#{@site.id}/settings"
    fill_in 'Site name', with: 'New site name'
    click_on 'Save'
    @site.reload
    assert_equal 'New site name', @site.name
  end

  test 'should allow editing of theme config' do
    login_as @site_admin
    visit "/bold/sites/#{@site.id}/settings"
    click_on 'Themes'
    click_link(@site.theme_name)
    assert has_content? 'presets'
    select 'homepage', from: 'Default template for posts'
    fill_in 'Subtitle', with: 'yay new subtitle!'
    click_on 'Save'

    @site.reload
    assert_equal 'homepage', @site.theme_config.default_post_template
    assert_equal 'yay new subtitle!', @site.theme_config.config['subtitle']
  end

end
