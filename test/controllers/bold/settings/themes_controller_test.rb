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

class Bold::Settings::ThemesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, params: { site_id: @site }
    assert_response :success
    assert assigns(:themes).any?
    assert_select '.left-col a.active', 'Themes'
    assert_select '.right-col h2', 'Themes'
  end

  test "should get edit" do
    get :edit, params: { site_id: @site, id: @site.theme_name }
    assert_response :success
    assert_equal @site.extension_configs.themes.last, assigns(:theme_config)
  end

  test 'should enable theme' do
    register_theme :foo do
      template :default
      template :page
      settings defaults: { a_setting: 'default value' }
    end
    put :enable, params: { site_id: @site, id: 'foo' }
    assert_redirected_to edit_bold_site_settings_theme_path(@site, 'foo')
    @site.reload
    assert_equal 'foo', @site.theme_name
  end

  test "should update theme config" do
    put :update,
      params: {
        site_id: @site,
        id: @site.theme_name,
        theme_config: {
          default_post_template: 'page',
          config: { subtitle: 'fancy subtitle', foo: 'bar' }
        }
      }
    assert_redirected_to bold_site_settings_themes_path(@site)
    @site.reload
    assert_equal 'page', @site.theme_config.default_post_template
    assert_equal 'fancy subtitle', @site.theme_config.config['subtitle']
    assert_equal 'bar', @site.theme_config.config['foo']
  end
end
