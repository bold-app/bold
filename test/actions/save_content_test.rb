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

class SaveContentTest < ActiveSupport::TestCase

  setup do
    Bold.current_site = @site = create :site
  end

  test 'should save new page' do
    assert_difference 'Page.count' do
      r = SaveContent.call @site.pages.build(title: 'new page', body: 'body')

      assert r.saved?
      assert r.message.present?
      assert_equal :notice, r.message_severity
      assert !r.published?
    end
    assert p = Page.find_by_title('new page')
    assert !p.published?
    assert_equal 'body', p.body
  end

  test 'should publish new page' do
    assert_difference 'Page.count' do
      r = SaveContent.call(
        @site.pages.build(title: 'new page', body: 'body'),
        publish: true
      )

      assert r.saved?
      assert r.message.present?
      assert_equal :notice, r.message_severity
      assert r.published?
    end
    assert p = Page.find_by_title('new page')
    assert p.published?
    assert_equal 'body', p.body
  end

  test 'should create page draft' do
    page = create :published_page, title: 'title', body: 'body'
    page.attributes = { title: 'draft title', body: 'draft body' }
    assert_no_difference 'Page.count' do
      assert_difference 'Draft.count' do
        r = SaveContent.call page
        assert r.saved?
        assert r.message.present?
        assert_equal :notice, r.message_severity
        assert !r.published?
      end
    end
    page.reload
    assert_equal 'title', page.title
    assert_equal 'body', page.body
  end


  test 'should save new post' do
    assert_difference 'Post.count' do
      assert_difference 'Tagging.count', 2 do
        r = SaveContent.call @site.posts.build(title: 'new post', body: 'body',
                                               tag_list: 'foo, bar')

        assert r.saved?
        assert r.message.present?
        assert_equal :notice, r.message_severity
        assert !r.published?
      end
    end

    assert p = Post.find_by_title('new post')
    assert !p.published?
    assert_equal 'body', p.body
    assert_equal 'bar, foo', p.tag_list
  end

  test 'should publish new post' do
    assert_difference 'Post.count' do
      assert_difference 'Tagging.count', 2 do
        r = SaveContent.call(
          @site.posts.build(title: 'new post', body: 'body',
                            tag_list: 'foo, bar'),
          publish: true
        )

        assert r.saved?
        assert r.message.present?
        assert_equal :notice, r.message_severity
        assert r.published?
      end
    end

    assert p = Post.find_by_title('new post')
    assert p.published?
    assert_equal 'body', p.body
    assert_equal 'bar, foo', p.tag_list
  end

  test 'should create post draft' do
    p = create :published_post, title: 'title', body: 'body'
    p.attributes = { title: 'draft title', body: 'draft body', tag_list: 'draft tag' }
    assert_no_difference 'Post.count' do
      assert_difference 'Draft.count' do
        r = SaveContent.call p
        assert r.saved?
        assert r.message.present?
        assert_equal :notice, r.message_severity
        assert !r.published?
      end
    end

    p.reload
    assert_equal 'title', p.title
    assert_equal 'body', p.body
    assert_equal '', p.tag_list
  end



end

