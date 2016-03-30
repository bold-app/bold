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

module Bold
  class AssetsControllerTest < ActionController::TestCase
    setup do
      @photo = create :asset, site: @site
      @text = create :textfile, site: @site
      @page = create :page, site: @site
    end

    test 'should show index' do
      get :index, params: { site_id: @site.id }
      assert_response :success
      assert_equal 2, assigns(:assets).size
      assert_equal @text, assigns(:assets).first
    end

    test 'should get new' do
      get :new, params: { site_id: @site.id }
      assert_response :success
    end

    test 'should get new for url' do
      get :new, params: { site_id: @site, source: 'url'}
      assert_response :success
    end

    test 'should create asset from url' do
      assert_difference 'Asset.count' do
        post :create_from_url, params: { site_id: @site, asset: { remote_file_url: 'https://oft-unterwegs.de/files/inline/7e9aaa6e-c1e4-48b6-8d70-e866ac01359f/teaser' }}
      end
    end

    test 'should handle empty url' do
      post :create_from_url, params: { site_id: @site, asset: { remote_file_url: '' }}
      assert_response :success
    end

    test 'should refuse bogus source' do
      get :new, params: { site_id: @site, source: 'foo'}
      assert_response 404
    end

    test 'should get edit' do
      get :edit, params: { id: @photo.id }
      assert_response :success
    end

    test 'should get edit xhr' do
      get :edit, xhr: true, params: { id: @photo.id }
      assert_response :success
    end

    test 'should send photo data' do
      get :show, params: { id: @photo.id }
      assert_response :success
      assert_equal @photo, assigns(:asset)
    end

    test 'should destroy photo' do
      assert_difference 'Asset.count', -1 do
        delete :destroy, params: { id: @photo.id }
      end
      assert_redirected_to bold_site_assets_path(@site)
      assert_equal 0, Asset.where(id: @photo.id).count
    end

    test 'should bulk destroy photos' do
      p = create :asset, site: @site
      assert_difference 'Asset.count', -2 do
        delete :bulk_destroy, params: {site_id: @site, ids: [@photo.id, p.id].join(','), format: :js }
      end
      assert_response :success
      assert_equal 0, Asset.where(id: [@photo.id, p.id]).count
    end
  end
end
