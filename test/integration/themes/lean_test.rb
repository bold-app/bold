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
  class LeanTest < ThemeIntegrationTest

    setup do
      @theme = @site.theme
    end

    def theme_name
      'lean'
    end

    test 'theme structure' do
      assert tpl = @theme.homepage_template
      assert_equal :homepage, tpl.key
      assert @theme.template? :archive
    end

    test 'should show homepage' do
      create_homepage
      visit '/'
    end

    test 'should show page' do
      publish_page title: 'Test Page Title', body: 'test page body', template: 'page'
      visit '/test-page-title'
      assert has_content? 'Test Page Title'
      assert has_content? 'test page body'
    end

    test 'should show post' do
      publish_post(
        title: 'Test Post Title',
        body: 'test post body',
        template: 'post',
        post_date: Time.local(2015, 02, 05),
        tag_list: 'foo, "bar baz"',
        author: @user,
        category: @category
      )

      visit '/2015/02/test-post-title'
      assert has_content? 'Test Post Title'
      assert has_content? 'test post body'
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
        assert has_content?('What a nice post!')
      end
    end

    test 'should show tag' do
      create_special_page :tag

      publish_post title: 'Test Post Title', tag_list: 'foo, bar'
      visit '/foo'
      assert has_content? 'Test Post Title'
      assert !has_content?('Test Page Title')
    end

    test 'should show archive' do
      publish_post(
        title: 'Test Post Title',
        body: 'test post body',
        post_date: Time.local(2015, 02, 05),
      )
      create_special_page :archive
      visit '/2015/02'
      assert has_content? 'Test Post Title'
      assert !has_content?('Test Page Title')
      visit '/2015'
      assert has_content? 'Test Post Title'
      assert !has_content?('Test Page Title')
      visit '/2014/02'
      assert !has_content?('Test Post Title')
      assert !has_content?('Test Page Title')
      visit '/2014'
      assert !has_content?('Test Post Title')
      assert !has_content?('Test Page Title')
    end


  end
end
