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
require 'bold/plugin'

class PluginTest < ActiveSupport::TestCase

  setup do
    register_plugin :foo do
      name 'Test Plugin'
      settings defaults: { bar: 2, foo: 'asdfg' }, partial: 'foo/settings'
    end
    @plugin = Bold::Plugin.all[:foo]
  end

  teardown do
    unregister_plugin :foo
  end

  test 'should be there' do
    assert @plugin.present?
    assert_equal @plugin, Bold::Plugin['foo']
  end

  test 'should have name' do
    assert_equal 'Test Plugin', @plugin.name
  end

  test 'should be configurable' do
    assert @plugin.configurable?
  end

  test 'should have settings' do
    assert_equal 'asdfg', @plugin.settings[:defaults][:foo]
  end

  test 'should have list of plugins' do
    assert Bold::Plugin.all.any?
  end
end