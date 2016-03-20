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

class PostTest < ActiveSupport::TestCase
  setup do
    Bold::current_site = @site = create :site
    @user = create(:confirmed_user)
    @post = create :post, author: @user
  end

  test 'should count words' do
    @post.body = 'Ruby 1.2 3 user@host.com hello.'
    assert_equal 5, @post.word_count
  end

  test 'should publish meta data' do
    post = create :post, author: @user, meta_title: 'meta title', meta_description: 'meta desc'
    post.publish!

    post.reload
    assert_equal 'meta title', post.meta_title
    assert_equal 'meta desc', post.meta_description
  end

  test 'should create permalink when published' do
    assert p = create(:post, title: 'My Great Post')
    assert_equal 'my-great-post', p.slug
    refute p.published?
    assert_nil p.permalink

    p.publish!
    p.reload
    assert p.published?
    assert l = p.permalink
    d = p.post_date
    assert_equal "#{d.year}/#{'%02d' % d.month}/my-great-post", l.path
  end

  test 'should keep permalink when republished' do
    assert p = create(:post, title: 'My Great Post')
    p.post_date_str = 'Aug 5, 2014'
    assert p.publish!
    assert_equal Time.parse('2014-08-05').to_date, p.post_date.to_date
    assert l = p.permalink
    assert_equal '2014/08/my-great-post', l.path
    p.title = 'Updated title'
    p.publish!
    p.reload

    assert l2 = p.permalink
    assert_equal l, l2
    assert_equal '2014/08/my-great-post', l2.path
  end

  test 'should redirect to new location when slug is changed' do
    post = create :published_post, slug: 'some-post', title: 'hello from site 1', body: 'lorem ipsum', site: @site
    assert pl = post.permalink
    assert_difference 'Redirect.count' do
      assert_difference 'Permalink.count' do
        post.update_attribute :slug, 'new-link'
      end
    end
    pl.reload
    assert r = pl.destination
    assert_equal Redirect, r.class
    assert_equal '/2014/07/new-link', r.location
    post.reload
    assert_equal '2014/07/new-link', post.permalink.path
  end

  test 'should find posts by author' do
    assert Post.authored_by(nil).blank?
    assert Post.authored_by('').blank?
    assert Post.authored_by('foo').blank?
    assert posts = Post.authored_by(@user.name)
    assert posts.include? @post
  end

  test 'should default to current user as author' do
    Bold.current_user = create :confirmed_user
    post = create :post
    assert_equal Bold.current_user, post.author
  end

  test 'should recognize break marker' do
    @post.update_attribute :body, "### some headline\n\nLorem ipsum\nnew line#{Post::BREAK_MARKER}After the break\n"
    assert teaser = @post.teaser_html(10)
    assert teaser =~ /new line/
    assert teaser !~ /(After|the|break)/
  end

  test 'should make teaser for n words' do
    @post.update_attribute :body, "### some headline\n\nLorem ipsum\nnew line here<!-- break -->and some more words that should not appear in teaser"
    assert teaser = @post.teaser_html(10)
    assert_match /new line/, teaser
    assert teaser !~ /(words|that|should|not|appear|teaser)/
  end

  test 'should remove unused tags after save' do
    @post.tag_list = 'removeme, "bar,baz"'
    assert @post.save

    assert_difference 'Tag.count', -1 do
      assert_difference 'Tagging.count', -1 do
        @post.tag_list = '"bar,baz"'
        assert @post.save
      end
    end
  end

  test 'should update tags' do
    @post.tag_list = 'bar, baz'
    assert @post.save

    assert_difference 'Tag.count' do
      assert_difference 'Tagging.count' do
        @post.tag_list = 'bar, baz, another'
        assert @post.save
      end
    end
  end

  test 'should create non published index when created' do
    assert post = Post.new(template: 'post', title: 'Search Test', body: 'lorem ipsum')
    assert_difference 'FulltextIndex.count', 1 do
      assert post.save
    end
    post.reload
    assert_equal 1, post.fulltext_indices.size
    assert idx = post.fulltext_indices.first
    assert !idx.published?
    assert_equal idx, FulltextIndex.search('lorem search').first
  end

  test 'should update non published index when updated' do
    assert post = Post.create(template: 'post', title: 'Search Test', body: 'lorem ipsum')
    assert_no_difference 'FulltextIndex.count' do
      post.update_attribute :body, 'the quick brown fox'
    end
    post.reload
    assert_equal 1, post.fulltext_indices.size
    assert idx = post.fulltext_indices.first
    assert !idx.published?
    assert_equal idx, FulltextIndex.search('brown fox').first
  end

  test 'should create published version of index when published' do
    @post.publish!
    @post.reload
    assert_equal 1, @post.fulltext_indices.size
    assert idx = @post.fulltext_indices.first
    assert idx.published?
    assert_equal idx, FulltextIndex.search(@post.title).first
  end

  test 'should have set up indexer' do
    assert Bold::Search::ContentIndexer === Post.indexer
  end

  test 'should rebuild index' do
    create :post, title: 'findme'
    assert FulltextIndex.search('findme').any?
    FulltextIndex.delete_all
    assert FulltextIndex.search('findme').blank?
    Content.rebuild_index
    assert FulltextIndex.search('findme').any?
  end

  test 'should maintain published and private version of index when published but edited' do
    @post.publish!; @post.reload
    assert_difference 'FulltextIndex.count', 1 do
      @post.update_attribute :body, 'the quick brown fox'
    end
    @post.reload
    assert_equal 2, @post.fulltext_indices.size
    assert FulltextIndex.published.search('fox').blank?
    assert_equal 1, FulltextIndex.search('fox').size
  end

  test 'should parse tags' do
    assert_equal %w(bar foo), @post.send(:parse_tags, 'foo, "bar"').sort
  end

  test 'should be taggable' do
    assert_no_difference 'Tag.count' do
      assert_no_difference 'Tagging.count' do
        @post.tag_list = 'foo, "bar,baz"'
      end
    end
    assert @post.changed?

    assert_difference '@site.tags.count', 2 do
      assert_difference '@post.taggings.count', 2 do
        @post.save
      end
    end

    assert_match /"bar,baz"/, @post.tag_list
    assert_match /foo/, @post.tag_list
    assert_equal [@post], Post.tagged_with('foo').to_a
    assert_equal [], Post.tagged_with('bar').to_a
  end

  test 'should publish and call ping job, but only the first time' do
    assert !@post.published?
    assert_enqueued_with job: RpcPingJob, args: [@post] do
      assert @post.publish!
    end
    assert @post.published?

    assert_no_enqueued_jobs do
      assert @post.publish!
    end
  end

  test 'should publish later' do
    now = Time.zone.now
    @post.post_date = now + 5.minutes
    assert_enqueued_with(job: PublisherJob, args: [@post]) do
      assert @post.publish!
    end
    assert @post.post_date > now
    assert !@post.published?
    assert @post.scheduled?

    @post.update_column :post_date, (now - 5.minutes)
    assert @post.scheduled?
    assert @post.publish!
    assert @post.published?
  end
end
