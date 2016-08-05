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

class SaveDraftTest < ActiveSupport::TestCase

  setup do
    @site = create :site
    Bold.current_site = @site
  end

  test 'saves empty page' do
    page = Page.new site: @site, title: 'blank page'
    assert SaveDraft.call(page), page.errors.inspect

    page.reload
    assert page.draft?
    assert !page.has_draft?
    assert_equal 'blank page', page.title
    assert page.body.blank?
  end

  test 'stores tags in draft' do
    post = create :published_post
    post.tag_list = 'foo'
    assert_difference 'Draft.count' do
      assert_no_difference 'Tagging.count' do
        assert SaveDraft.call(post)
      end
    end

    post.reload
    assert post.has_draft?
    assert_equal '', post.tag_list
    post.load_draft
    assert_equal 'foo', post.tag_list
  end

  test 'stores tags in unpublished post' do
    post = Post.new site: @site, tag_list: 'foo', title: 'new post'
    assert_no_difference 'Draft.count' do
      assert_difference 'Post.count' do
        assert_difference 'Tagging.count' do
          assert SaveDraft.call(post)
        end
      end
    end

    post.reload
    assert !post.has_draft?
    assert post.draft?
    assert !post.published?
    assert_equal 'foo', post.tag_list
  end

  test 'changed published page should save draft' do
    page = create :published_page
    assert !page.has_draft?
    page.title = 'new title'
    page.body = 'new body'
    assert SaveDraft.call(page)

    page.reload
    assert page.has_draft?
    assert page.draft.drafted_changes.key?('title'), page.draft.inspect
    assert page.draft.drafted_changes.key?('body'), page.draft.inspect

    page.reload
    assert_equal 'This is a Page', page.title
    assert_match /### H3 here/, page.body

    assert_equal 'new title', page.draft.drafted_changes['title']
    assert_equal 'new body', page.draft.drafted_changes['body']
    page.load_draft
    assert_equal 'new title', page.title
    assert_equal 'new body', page.body
  end

  test 'new page should not save draft' do
    page = Page.new title: 'new page', body: 'new content', site: @site
    assert_difference 'Page.count', 1 do
      assert_no_difference 'Draft.count' do
        assert SaveDraft.call(page)
      end
    end

    page.reload
    assert page.draft?
    assert !page.published?
    assert !page.has_draft?
    assert !page.draft.present?
    assert_equal 'new page', page.title
    assert_equal 'new content', page.body
  end

end
