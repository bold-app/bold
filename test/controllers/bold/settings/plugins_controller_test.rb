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

class Bold::Settings::PluginsControllerTest < ActionController::TestCase
  setup do
    register_plugin :dummy do
      name 'Test plugin'
    end
  end

  teardown do
    unregister_plugin :dummy
  end

  test "should get index" do
    get :index
    assert_response :success
    assert assigns(:plugins).any?
    assert_select '.left-col a.active', 'Plugins'
    assert_select '.right-col h2', 'Plugins'
  end

  test "should get edit" do
    get :edit, id: 'dummy'
    assert_response :success
    assert plugin_config = assigns(:plugin_config)
    assert_equal 'dummy', plugin_config.name
  end

  test 'should update config' do
    @site.enable_plugin! 'dummy'
    put :update, id: 'dummy', plugin_config: { config: { 'foo' => 'bar' } }
    assert_redirected_to bold_settings_plugins_path
    cfg = @site.plugin_config 'dummy'
    assert_equal 'bar', cfg.config['foo']
  end

  test 'should activate plugin' do
    assert_nil @site.plugins.detect{|p| p.name == 'dummy'}
    put :enable, id: 'dummy'
    assert_redirected_to edit_bold_settings_plugin_path('dummy')
    assert @site.plugins.detect{|p| p.name == 'dummy'}
  end

  test 'should handle invalid plugin' do
    assert_raise(Bold::PluginNotFound) do
      put :enable, id: 'foo'
    end
  end

  test 'should deactivate plugin' do
    @site.enable_plugin! 'dummy'
    assert @site.plugins.detect{|p| p.name == 'dummy'}
    delete :destroy, id: 'dummy'
    assert_redirected_to bold_settings_plugins_path
    assert_nil @site.plugins.detect{|p| p.name == 'dummy'}
  end
end