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
      @post = create :published_post, site: @site
      @site.update_attribute :post_comments, 'enabled'
      @comment = create :comment, content: @post, site: @site
      @contact_page = create :published_page, template: 'contact_page', site: @site
      @contact_msg = create :contact_message, content: @contact_page, site: @site
    end

    test 'should get index' do
      get :index, params: { site_id: @site }
      assert_response :success
      assert assigns(:postings).include?(@comment)
    end

    test 'should filter comments by state' do
      get :index, params: { site_id: @site, comment_search: { status: 'pending' } }
      assert_response :success
      assert_select "article#comment_#{@comment.id} p", /#{@comment.author_email}/

      get :index, params: { site_id: @site, comment_search: { status: 'approved' } }
      assert_response :success
      assert_select "article#comment_#{@comment.id}", count: 0
    end

    test 'should delete all spam' do

      @comment.spam!
      assert_difference 'VisitorPosting.count', -1 do
        delete :destroy_spam, params: { site_id: @site }
      end
      assert_redirected_to bold_site_activity_comments_path(@site)
      assert_raise(ActiveRecord::RecordNotFound){ @comment.reload }
    end

    test 'should change state' do
      patch :unapprove, xhr: true, params: { id: @comment }
      assert_response :success
      @comment.reload
      assert @comment.pending?

      patch :approve, xhr: true, params: { id: @comment }
      assert_response :success
      @comment.reload
      assert @comment.approved?

      @comment.spam!

      patch :mark_ham, xhr: true, params: { id: @comment }
      assert_response :success
      @comment.reload
      assert @comment.pending?


      assert_no_difference 'Comment.count', -1 do
        assert_difference 'Comment.existing.count', -1 do
          patch :mark_spam, xhr: true, params: { id: @comment }
          assert_response :success
        end
      end

    end

    test 'should delete contact_message' do
      assert_no_difference 'ContactMessage.count' do
        assert_difference 'ContactMessage.existing.count', -1 do
          assert_difference 'Memento::Session.count' do
            assert_difference 'Memento::State.count' do
              delete :destroy, xhr: true, params: { id: @contact_msg }
            end
          end
        end
      end
    end

    test 'should delete comment' do
      assert_no_difference 'Comment.count' do
        assert_difference 'Comment.existing.count', -1 do
          assert_difference 'Memento::Session.count' do
            assert_difference 'Memento::State.count' do
              delete :destroy, xhr: true, params: { id: @comment }
            end
          end
        end
      end
    end

  end
end
