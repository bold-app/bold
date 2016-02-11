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

class ThemeConfigTest < ActiveSupport::TestCase

  test 'should have sensible defaults' do
    cfg = ThemeConfig.new name: 'test'
    cfg.send :set_defaults
    assert_equal 'page', cfg.default_page_template
    assert_equal 'post', cfg.default_post_template
    assert cfg.configured?
  end

  test 'should update config hash from nested attributes' do
    cfg = ThemeConfig.new
    cfg.attributes = { default_page_template: 'page_tpl', config: { foo: 'bar' } }
    assert_equal 'page_tpl', cfg.default_page_template
    assert cfg.config.key?('default_page_template')
    assert_equal 'page_tpl', cfg.config['default_page_template']
    assert cfg.config.key?('foo')
    assert_equal 'bar', cfg.config['foo']
  end
end