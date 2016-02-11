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

class ContentDecoratorTest < Draper::TestCase

  setup do
    Bold.current_site = @site = create :site
    @post = create :published_post
    @decorated = ContentDecorator.decorate @post

    Draper::ViewContext.test_strategy :fast do
      include ApplicationHelper
      include FrontendHelper
      include Rails.application.routes.url_helpers
      def site
        Bold.current_site.decorate
      end
    end
  end

  #
  # Template field value retrieval
  #

  test 'should raise no method error for non declared fields' do
    page = create :page, site: @site, template: 'post',
      template_field_values: {'foo' => 'bar'}
    page = page.decorate
    assert_nil page['foo']
    assert_nil page[:foo]
    assert !page.respond_to?(:foo)
    assert_raise(NoMethodError){ page.foo }
    assert !page.respond_to?(:foo?)
    assert_raise(NoMethodError){ page.foo? }
  end

  test 'should store and retrieve template field values' do
    page = create :page, site: @site, template: 'post',
      template_field_values: {'test' => 'value'}
    page = page.decorate
    assert_equal 'value', page['test']
    assert page.respond_to?(:test)
    assert_equal 'value', page.test
    assert page.respond_to?(:test?)
    assert_equal true, page.test?
  end

  test 'should retrieve false for zero value' do
    page = create :page, site: @site, template: 'post',
      template_field_values: {'test' => '0'}
    page = page.decorate
    assert_equal '0', page['test']
    assert_equal '0', page.test
    assert_equal false, page.test?
  end

  test 'should retrieve false for nil value' do
    page = create :page, site: @site, template: 'post'
    page = page.decorate
    assert_nil page['test']
    assert_nil page.test
    assert_equal false, page.test?
  end

  test 'should retrieve false for blank value' do
    page = create :page, site: @site, template: 'post',
      template_field_values: {'test' => ''}
    page = page.decorate
    assert_equal '', page['test']
    assert_equal '', page.test
    assert_equal false, page.test?
  end

end