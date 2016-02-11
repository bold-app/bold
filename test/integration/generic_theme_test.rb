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

# generic theme test case.
#
# The theme to be tested is set by the BOLD_THEME environment variable:
#
# BOLD_THEME=casper TEST=test/integration/theme_test.rb bundle exec rake
#
class GenericThemeTest < ThemeIntegrationTest

  puts "Testing the #{ENV['BOLD_THEME'] || 'test'} theme."

  setup do
    @theme_name = ENV['BOLD_THEME'] || 'test'
    setup_site @theme_name
  end

  test 'check special pages' do
    assert @homepage_tpl.present?, 'should have homepage template'
    assert @site.homepage.present?

    if @tag_tpl
      assert @site.tag_page.present?, 'should have tag page'
    end
    if @archive_tpl
      assert @site.archive_page.present?, 'should have archive page'
    end
    if @category_tpl
      assert @site.category_page.present?, 'should have category page'
    end
    if @author_tpl
      assert @site.author_page.present?, 'should have author page'
    end
  end

  test 'should show homepage' do
    visit '/'
  end

  test 'should show page' do
    if @page
      visit '/test-page-title'
      assert has_content? 'Test Page Title'
      assert has_content? 'test page body'
    end
  end

  test 'should show post' do
    if @post
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
  end

  test 'should show category' do
    if @post
      visit '/a-category'
      assert has_content? 'Test Post Title'
      assert !has_content?('Test Page Title')
    end
  end

  test 'should show tag' do
    if @post
      visit '/foo'
      assert has_content? 'Test Post Title'
      assert !has_content?('Test Page Title')
    end
  end

  test 'should show archive' do
    if @archive_tpl
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