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

module Bold::Activity
  class CommentsControllerTest < ActionController::TestCase
    setup do
      @post = create :published_post
      @site.update_attribute :post_comments, 'enabled'
      @comment = create :comment, content: @post, site: @site
    end

    test 'should get index' do
      get :index
      assert_response :success
      assert assigns(:postings).include?(@comment)
    end

    test 'should filter comments by state' do
      get :index, comment_search: { status: 'pending' }
      assert_response :success
      assert assigns(:postings).include?(@comment)

      get :index, comment_search: { status: 'approved' }
      assert_response :success
      assert assigns(:postings).blank?
    end

    test 'should change state' do
      xhr :patch, :unapprove, id: @comment
      assert_response :success
      @comment.reload
      assert @comment.pending?

      xhr :patch, :approve, id: @comment
      assert_response :success
      @comment.reload
      assert @comment.approved?

      @comment.spam!

      xhr :patch, :mark_ham, id: @comment
      assert_response :success
      @comment.reload
      assert @comment.pending?


      assert_no_difference 'Comment.count', -1 do
        assert_difference 'Comment.alive.count', -1 do
          xhr :patch, :mark_spam, id: @comment
          assert_response :success
        end
      end

    end

    test 'should destroy comment' do
      assert_difference 'Comment.alive.count', -1 do
        assert_difference 'Memento::Session.count' do
          assert_difference 'Memento::State.count' do
            xhr :delete, :destroy, id: @comment
          end
        end
      end
    end

  end
end
