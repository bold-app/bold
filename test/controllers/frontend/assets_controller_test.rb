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

module Frontend
  class AssetsControllerTest < ActionController::TestCase

    test 'should show hi res asset if enabled' do
      @asset = create_asset
      @site.update_attributes adaptive_images: '1'
      @request.cookies['boldScreenSize'] = '2'
      get :show, params: { id: @asset.to_param, version: 'big' }
      assert_response :success
      assert disp = @response.headers['Content-Disposition']
      assert_equal "inline; filename=\"big_2x_#{@asset.filename}\"", disp
    end

    test 'should show 3x hi res asset' do
      @asset = create_asset
      @site.update_attributes adaptive_images: '1'
      @request.cookies['boldScreenSize'] = '3|736' # iphone 6+
      get :show, params: { id: @asset.to_param, version: 'big' }
      assert_response :success
      assert disp = @response.headers['Content-Disposition']
      assert_equal "inline; filename=\"big_mobile_3x_#{@asset.filename}\"", disp
    end

    test 'should set dpr cookie' do
      get :display_config, params: { dpr: 2, res: 1024 }
      assert_response 204
      assert_equal 2, session[:dpr]
      assert_equal 1024, session[:res]
    end

    test 'should ignore invalid dpr' do
      get :display_config, params: { dpr: 4 }
      assert_response 204
      assert_nil session[:dpr]
      assert_nil session[:res]
    end

    test 'should ignore missing res' do
      get :display_config, params: { dpr: 2 }
      assert_response 204
      assert_equal 2, session[:dpr]
      assert_nil session[:res]
    end

    test 'should show asset' do
      @asset = create_asset
      get :show, params: { id: @asset.to_param }
      assert_response :success
      assert disp = @response.headers['Content-Disposition']
      assert_equal "inline; filename=\"#{@asset.filename}\"", disp
    end

    test 'should download asset' do
      @asset = create_asset
      get :download, params: { id: @asset.to_param, filename: 'foo.pdf' }
      assert_response :success
      assert disp = @response.headers['Content-Disposition']
      assert_equal "attachment; filename=\"#{@asset.filename}\"", disp
    end

  end

end
