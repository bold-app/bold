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

class Bold::Settings::HtmlSnippetsControllerTest < ActionController::TestCase

  test 'should render edit' do
    get :edit, params: { site_id: @site }
    assert_response :success
  end

  test 'should update snippets' do
    patch :update, params: { site_id: @site,
                             site: { html_head_snippet: 'foo bar' }}
    assert_redirected_to edit_bold_site_settings_html_snippet_path(@site)
    @site.reload
    assert_equal 'foo bar', @site.html_head_snippet
  end

end

