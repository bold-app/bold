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

class ThemeTest < ActiveSupport::TestCase

  setup do
    register_theme :foobar_themetest do
      template :homepage, body: false
      template :page, fields: { foo: 'bar' }
      template :post
      template :foobar, for: :tag
      locales %i(de en)
      settings partial: 'foo_settings'
    end
    @theme = Bold::Theme[:foobar_themetest]
  end

  teardown do
    unregister_theme :foobar_themetest
    unregister_theme :another_theme
  end

  test 'should recognize homepage template named different' do
    register_theme :another_theme do
      template :home, for: :homepage, body: false
      template :page, fields: %w(cover_image)
    end
    assert t = Bold::Theme['another_theme']
    assert tpl = t.homepage_template
    assert_equal :home, tpl.key
  end

  test 'should have content templates' do
    assert templates = @theme.content_templates.map(&:key)
    %i(page post foobar).each do |t|
      assert templates.include?(t), "should include #{t} template"
    end
  end

  test 'should be configurable' do
    assert @theme.configurable?
    assert_nil @theme.default_settings[:foo]
    assert_equal [:de, :en], @theme.locales
  end

  test 'should have default settings' do
    register_theme :another_theme do
      template :default
      layout 'other'
      settings defaults: {foo: 'bar'}
    end
    assert theme = Bold::Theme['another_theme']
    assert theme.configurable?
    assert_equal 'bar', theme.default_settings[:foo]
    assert_equal 'other', theme.layout
  end

  test 'should be registered' do
    assert @theme.present?
    assert_equal @theme, Bold::Theme['foobar_themetest']
    assert_nil @theme.layout
  end

  test 'should have fields' do
    assert @theme.template('page').fields?
    assert_equal 'bar', @theme.template('page').fields[:foo]
    assert !@theme.template('post').fields?
  end

  test 'should have base dir' do
    assert_equal 'themes/foobar_themetest', @theme.send(:template_dir)
  end

  test 'should have templates' do
    assert_equal 4, @theme.templates.size
    assert t = @theme.template('page')
    assert_equal 'themes/foobar_themetest/page', t.file
    assert t.has_body?
  end

  test 'should find template by usage' do
    assert tpl = @theme.find_template(:tag)
    assert_equal :foobar, tpl.key
  end

  test 'template registration without body' do
    assert t = @theme.template(:homepage)
    assert !t.has_body?
  end

  test 'should have list of themes' do
    assert Bold::Theme.all.size > 1
    assert Bold::Theme.all.key?(:test)
    assert Bold::Theme.all.key?(:foobar_themetest)
  end
end