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

class Bold::Settings::CategoriesControllerTest < ActionController::TestCase
  setup do
    @cat = create :category, name: 'Test Category', site: @site
  end

  test 'should render index' do
    get :index, params: { site_id: @site.id }
    assert_response :success
    assert_select 'h4', /Test Category/
  end

  test 'should create category and init slug' do
    assert_difference '@site.categories.count' do
      post :create, params: { site_id: @site.id, category: { name: 'Neue Kategorie' } }
    end
    assert_redirected_to bold_site_settings_categories_url(@site)
    assert @site.categories.find_by_slug('neue-kategorie')
  end

  test 'should update category' do
    patch :update, params: { id: @cat.id, category: { name: 'new name', slug: 'foobar' } }
    assert_redirected_to bold_site_settings_categories_url(@site)
    @cat.reload
    assert_equal 'new name', @cat.name
    assert_equal 'foobar', @cat.slug
  end

  test 'should get new' do
    get :new, params: { site_id: @site.id }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @cat.id }
    assert_response :success
  end

  test 'should delete category' do
    assert_difference '@site.categories.count', -1 do
      delete :destroy, params: { id: @cat.to_param }
    end
  end

end
