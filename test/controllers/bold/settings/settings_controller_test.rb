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

class Bold::Settings::SettingsControllerTest < ActionController::TestCase

  test "should get edit and render site config" do
    get :edit
    assert_response :success
    assert_select '.right-col h2', 'General'
    assert_select '.left-col a.active', 'General'
  end

  test "should update site" do
    patch :update, params: { site: { name: 'new name', url_scheme: 'http', hostname: 'somewhere.de' } }
    assert_redirected_to bold_settings_root_path
    @site.reload
    assert_equal 'new name', @site.name
    assert_equal 'http://somewhere.de/', @site.external_url
  end

end
