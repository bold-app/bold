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

class TemplateTest < ActiveSupport::TestCase

  setup do
    register_theme :template_test do
      template :homepage, body: false, fields: %w(greeting)
      template :default
    end
    @theme = Bold::Theme[:template_test]
  end

  teardown do
    unregister_theme :template_test
  end

  test 'should have variables' do
    assert tpl = @theme.template(:homepage)
    assert tpl.fields?
    assert tpl.fields.include? 'greeting'
  end

  test 'should not have body' do
    assert tpl = @theme.template(:homepage)
    assert !tpl.body?
  end

  test 'should have pretty name' do
    assert_equal 'Homepage', @theme.template(:homepage).pretty_name
  end

  test 'should have body' do
    assert tpl = @theme.template(:default)
    assert tpl.body?
    assert !tpl.fields?
  end

  test 'should expand usage key to alternatives' do
    assert_equal %i(not_found page default), Bold::Template.expand_usage(:not_found)
  end

end