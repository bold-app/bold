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

class PublishContentTest < ActiveSupport::TestCase

  setup do
    @site = create :site
    Bold.current_site = @site
  end

  test 'should publish unsaved record' do
    p = Page.new title: 'my new page'
    assert_difference 'Page.count' do
      assert PublishContent.call(p), p.errors.inspect
    end
  end

  test 'should create permalink when published' do
    assert p = Page.create(title: 'My Great Page')
    assert_equal 'my-great-page', p.slug
    refute p.published?
    assert_nil p.permalink

    PublishContent.new(p).call

    p.reload
    assert p.published?
    assert l = p.permalink
    assert_equal 'my-great-page', l.path
  end

  test 'should keep permalink when republished' do
    assert p = create(:post, title: 'My Great Post')

    p.post_date_str = 'Aug 5, 2014'
    PublishContent.new(p).call
    p.reload

    assert_equal Time.parse('2014-08-05').to_date, p.post_date.to_date
    assert l = p.permalink
    assert_equal '2014/08/my-great-post', l.path

    p.title = 'Updated title'
    PublishContent.new(p).call
    p.reload

    assert l2 = p.permalink
    assert_equal l, l2
    assert_equal '2014/08/my-great-post', l2.path
  end

  test 'should replace old redirect when published' do
    p = publish_page title: 'My Great Page'

    assert p.published?
    assert l = p.permalink
    assert_equal p, l.destination
    assert_equal 'my-great-page', l.path

    assert_difference 'Permalink.count' do
      assert_difference 'Redirect.count' do
        p.slug = 'new-slug'
        PublishContent.new(p).call
      end
    end

    p2 = nil
    assert_no_difference 'Permalink.count' do
      assert_difference 'Redirect.count', -1 do
        p2 = publish_page(title: 'My Great Page')
      end
    end
    l.reload
    assert_equal p2, l.destination
  end

  test 'should redirect to new location when slug change is published' do
    post = publish_post title: 'Some post', body: 'lorem ipsum', post_date: '2014-07-20'

    assert pl = post.permalink
    assert_equal post, pl.destination
    assert_equal '2014/07/some-post', pl.path

    assert_difference 'Redirect.count' do
      assert_difference 'Permalink.count' do
        post.slug = 'new-link'
        assert PublishContent.call(post)
      end
    end

    post.reload
    pl.reload
    assert r = pl.destination
    assert_equal Redirect, r.class
    assert_equal '/2014/07/new-link', r.location
    assert_equal '2014/07/new-link', post.permalink.path
  end


  test 'page should remove draft upon republish' do
    page = publish_page
    save_draft page, 'body': 'new body'

    page.reload
    assert page.has_draft?
    page.load_draft
    assert_equal 'new body', page.body

    page.body = 'changed again'
    assert_difference 'Draft.count', -1 do
      PublishContent.new(page).call
    end

    page.reload
    assert page.last_update
    assert !page.has_draft?
    assert_equal 'changed again', page.body
  end

  test 'should publish and call ping job, but only the first time' do
    post = nil
    assert_enqueued_with job: RpcPingJob do
      post = publish_post
    end

    assert_no_enqueued_jobs do
      post.title = 'new title'
      assert PublishContent.new(post).call
    end
  end

  test 'should publish later' do
    now = Time.zone.now

    post = nil
    assert_enqueued_with(job: PublisherJob) do
      post = publish_post post_date: now + 5.minutes
    end
    assert post.post_date > now
    assert !post.published?
    assert post.scheduled?

    post.update_column :post_date, (now - 5.minutes)
    assert post.scheduled?
    assert PublishContent.new(post).call
    post.reload
    assert post.published?
  end

  private

  def save_draft(content, changes)
    Draft.create! content: content, drafted_changes: changes
  end
end
