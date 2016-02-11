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

class CommentTest < ActiveSupport::TestCase
  setup do
    @site = create :site
    @post = create :published_post
    configure 'enabled'
  end

  test 'should refuse creation on non-published post' do
    post = create :post, title: 'not published'
    assert_raise(ActiveRecord::RecordInvalid) do
      create :comment, post: post
    end
  end

  test 'should refuse creation when configured' do
    configure nil
    assert_raise(ActiveRecord::RecordInvalid) do
      create :comment, post: @post
    end
  end

  test 'should take site from post' do
    co = create :comment, post: @post
    assert_equal @post.site, co.site
  end

  test 'should be pending by default' do
    co = create :comment, post: @post
    assert co.pending?
  end

  test 'mark spam should delete and enqueue job' do
    co = create :comment, post: @post
    assert_difference 'Comment.count', -1 do
      assert_enqueued_with(job: CommentAkismetUpdateJob) do
        co.mark_as_spam!
      end
    end
  end

  test 'mark ham should change status and enqueue job' do
    co = create :comment, post: @post
    co.spam!
    assert_enqueued_with(job: CommentAkismetUpdateJob) do
      co.mark_as_ham!
    end
    co.reload
    assert co.pending?
  end

  def configure(comment_config)
    @site.update_attribute :post_comments, comment_config
  end
end