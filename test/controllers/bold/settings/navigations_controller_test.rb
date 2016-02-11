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

class Bold::Settings::NavigationsControllerTest < ActionController::TestCase
  setup do
    @nav = create :navigation, name: 'Test', url: 'http://foo.bar/'
    @nav.move_to_bottom
  end

  test 'should render index' do
    get :index
    assert_response :success
    assert_select 'input[value=Home]'
    assert_select 'input[value=Test]'
  end

  test 'should update nav' do
    xhr :patch, :update, id: @nav.id, navigation: { name: 'new', url: 'foobar' }
    assert_response :success
    @nav.reload
    assert_equal 'new', @nav.name
    assert_equal 'foobar', @nav.url
  end

  test 'should create nav' do
    assert_difference '@site.navigations.count' do
      xhr :post, :create, navigation: { name: 'Bold', url: 'http://bold-app.org/' }
    end
    assert_response :success
  end

  test 'should delete nav' do
    assert_difference '@site.navigations.count', -1 do
      xhr :delete, :destroy, id: @nav.to_param
    end
  end

  test 'should reorder navs' do
    nav2 = create :navigation, name: 'Another', url: '/'
    nav2.move_to_bottom
    assert nav2.last?
    @nav.reload
    refute @nav.last?
    assert_equal @nav.position + 1, nav2.position
    xhr :put, :sort, id: nav2.id, new_position: @nav.position - 1
    @nav.reload
    nav2.reload
    assert @nav.last?
    assert_equal @nav, nav2.lower_item
  end
end