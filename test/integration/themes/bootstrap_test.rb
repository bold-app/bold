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

module Themes
  class BootstrapTest < ThemeIntegrationTest

    setup do
      setup_site 'bootstrap'
    end

    test 'theme structure' do
      assert theme = Bold::Theme['bootstrap']
      assert tpl = theme.homepage_template
      assert_equal :default, tpl.key
    end

    test 'check special pages' do
      check_special_pages except: %w(author_page search_page archive_page tag_page category_page)
    end

    test 'should show page and post' do
      visit '/'
      visit '/test-page-title'
      assert has_content? 'test page body'
      visit '/2015/02/test-post-title'
      assert has_content? 'test post body'
    end

  end
end