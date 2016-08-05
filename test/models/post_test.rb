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
  end

  test 'should count words' do
    @post = create :post, author: @user
    @post.body = 'Ruby 1.2 3 user@host.com hello.'
    assert_equal 5, @post.word_count
  end

  test 'should publish meta data' do
    post = publish_post author: @user, meta_title: 'meta title', meta_description: 'meta desc'

    post.reload
    assert_equal 'meta title', post.meta_title
    assert_equal 'meta desc', post.meta_description
  end

  test 'should find posts by author' do
    @post = create :post, author: @user
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
    @post = create :post, author: @user
    @post.update_attribute :body, "### some headline\n\nLorem ipsum\nnew line#{Post::BREAK_MARKER}After the break\n"
    assert teaser = @post.teaser_html(10)
    assert teaser =~ /new line/
    assert teaser !~ /(After|the|break)/
  end

  test 'should make teaser for n words' do
    @post = create :post, author: @user
    @post.update_attribute :body, "### some headline\n\nLorem ipsum\nnew line here<!-- break -->and some more words that should not appear in teaser"
    assert teaser = @post.teaser_html(10)
    assert_match /new line/, teaser
    assert teaser !~ /(words|that|should|not|appear|teaser)/
  end


  test 'should build data for indexing' do
    p = publish_post title: 'the title',
                     meta_title: 'meta title',
                     meta_description: 'meta desc',
                     body: 'the body',
                     tag_list: 'foo, bar',
                     category: create(:category, name: 'Category')
    assert data = p.data_for_index
    assert_equal 4, data.size
    assert title = data[:a]
    assert_equal 'the title', title[0]
    assert_equal 'meta title', title[1]
    assert_equal 'the body', data[:d]
    assert_equal 'bar, foo Category', data[:b]
    assert_nil data[:c][0]
    assert_equal 'meta desc', data[:c][1]
  end
end
