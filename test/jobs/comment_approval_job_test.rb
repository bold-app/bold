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

class CommentApprovalJobTest < ActiveJob::TestCase

  setup do
    Bold.current_site = create :site
    configure 'enabled'
    @post = create :published_post
    @comment = create :comment, content: @post
  end

  test 'should auto-approve when not spam and configured to do so' do
    SpamCheck.any_instance.
      stubs(:call).
      returns(SpamCheck::Result.new)

    assert @comment.pending?
    CommentApprovalJob.perform_now(@comment)
    @comment.reload
    assert @comment.approved?
  end

  test 'should not auto-approve when spam' do
    SpamCheck.any_instance.
      stubs(:call).
      returns(SpamCheck::Result.new(spam: true))

    assert @comment.pending?
    CommentApprovalJob.perform_now(@comment)
    @comment.reload
    assert @comment.spam?
  end

  test 'should hold for approval when configured' do
    configure 'with_approval'
    SpamCheck.any_instance.
      stubs(:call).
      returns(SpamCheck::Result.new)

    assert @comment.pending?
    CommentApprovalJob.perform_now(@comment)
    @comment.reload
    assert @comment.pending?
  end

  test 'should destroy blatant spam' do
    SpamCheck.any_instance.
      stubs(:call).
      returns(SpamCheck::Result.new(spam: true, blatant: true))

    assert @comment.pending?

    assert_difference 'Comment.existing.count', -1 do
      CommentApprovalJob.perform_now(@comment)
    end
  end

  def configure(comment_config)
    Site.current.update_attribute :post_comments, comment_config
  end

end
