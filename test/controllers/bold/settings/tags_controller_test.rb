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

class Bold::Settings::TagsControllerTest < ActionController::TestCase
  setup do
    @tag = create :tag, name: 'Test Tag', site: @site
  end

  test 'should render index' do
    get :index, params: { site_id: @site.to_param }
    assert_response :success
    assert_select 'td', /Test Tag/
  end

  test 'should get edit' do
    get :edit, params: { id: @tag.to_param }
    assert_response :success
  end

  test 'should update tag' do
    patch :update, params: { id: @tag.to_param,
                             tag: { name: 'new name', slug: 'foobar' } }
    assert_redirected_to bold_site_settings_tags_url(@site)
    @tag.reload
    assert_equal 'new name', @tag.name
    assert_equal 'foobar', @tag.slug
  end

  test 'should delete tag' do
    assert_difference '@site.tags.count', -1 do
      delete :destroy, params: { id: @tag.to_param }
    end
  end

end

