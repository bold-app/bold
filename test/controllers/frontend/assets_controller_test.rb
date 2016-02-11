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

    setup do
      @asset = create :asset
    end

    test 'should show asset' do
      get :show, id: @asset.to_param
      assert_response :success
      assert disp = @response.headers['Content-Disposition']
      assert_equal "inline; filename=\"#{@asset.filename}\"", disp
    end

    test 'should download asset' do
      get :download, id: @asset.to_param, filename: 'foo.pdf'
      assert_response :success
      assert disp = @response.headers['Content-Disposition']
      assert_equal "attachment; filename=\"#{@asset.filename}\"", disp
    end

    test 'should create request log for asset' do
      assert_difference 'RequestLog.count' do
        get :show, id: @asset.to_param
      end
      assert l = RequestLog.order('created_at').last
      assert_equal 200, l.status
      assert_equal @asset, l.resource
      assert_equal @asset.site, l.site
      assert_match /^inline/, l.response['disposition']
    end
  end

end