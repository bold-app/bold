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

class Admin::ImportsControllerTest < ActionController::TestCase

  setup do
    @admin = create :confirmed_admin
    sign_in :user, @admin
  end

  test "should get new" do
    get :new, site_id: @site.to_param
    assert_response :success
  end

  test "should import" do
    assert_equal 'homepage', @site.homepage.slug
    assert @site.homepage.body.blank?
    upload = fixture_file_upload 'export.zip'
    assert_difference '@site.contents.size' do
      post :create, site_id: @site.to_param, site_import: { zipfile: upload }
    end
    @site.reload
    assert_equal 'this is the homepage', @site.homepage.body
  end

end