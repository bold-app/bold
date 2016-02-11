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
      @photo = create :asset
      @text = create :textfile
      @page = create :page
    end

    test 'should show index' do
      get :index
      assert_response :success
      assert_equal 2, assigns(:assets).size
      assert_equal @text, assigns(:assets).first
    end

    test 'should get edit' do
      xhr :get, :edit, id: @photo.id
      assert_response :success
    end

    test 'should send photo data' do
      get :show, id: @photo.id
      assert_response :success
      assert_equal @photo, assigns(:asset)
    end

    test 'should destroy photo' do
      assert_difference 'Asset.count', -1 do
        delete :destroy, id: @photo.id
      end
      assert_redirected_to bold_assets_path
      assert_equal 0, Asset.where(id: @photo.id).count
    end

    test 'should bulk destroy photos' do
      p = create :asset
      assert_difference 'Asset.count', -2 do
        delete :bulk_destroy, ids: [@photo.id, p.id].join(','), format: :js
      end
      assert_response :success
      assert_equal 0, Asset.where(id: [@photo.id, p.id]).count
    end
  end
end