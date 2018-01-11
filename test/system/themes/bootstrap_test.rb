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
require 'application_system_test_case'

module Themes
  class BootstrapTest < ApplicationSystemTestCase

    def theme_name
      'bootstrap'
    end

    test 'theme structure' do
      assert tpl = @site.theme.homepage_template
      assert_equal :default, tpl.key
    end

    test 'should show homepage' do
      create_homepage
      visit '/'
    end

    test 'should show page' do
      publish_page title: 'Test Page Title',
                   body: 'test page body',
                   template: 'default'
      visit '/test-page-title'
      assert_text 'test page body'
    end

    test 'should show post' do
      publish_post(
        title: 'Test Post Title',
        body: 'test post body',
        template: 'default',
        post_date: Time.local(2015, 02, 05),
        tag_list: 'foo, "bar baz"',
        author: @user,
        category: @category
      )

      visit '/2015/02/test-post-title'
      assert_text 'test post body'
      if has_comment_form?
        fill_in 'comment_author_name', with: 'Max Muster'
        fill_in 'comment_author_email', with: 'user@host.com'
        fill_in 'comment_body', with: 'What a nice post!'
        assert_difference 'Comment.count' do
          click_on 'comment_submit'
        end
        assert !has_content?('What a nice post!')

        assert c = @site.comments.last
        assert c.pending?
        c.approved!

        visit '/2015/02/test-post-title'
        assert_text('What a nice post!')
      end
    end

  end
end
