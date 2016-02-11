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
module Bold::Activity
  class CommentsController < BoldController
    before_action :set_comment, except: :index

    def index
      @comment_search = CommentSearch.new search_params
      @comments = @comment_search.search(current_site.comments.includes(:post)).
        order('created_at DESC').page(params[:page]).per(20)
    end

    def approve
      @comment.approved!
      render 'update'
    end

    def unapprove
      @comment.pending!
      render 'update'
    end

    def restore
      @comment.undelete!
      render 'update'
    end

    def mark_ham
      memento do
        @comment.mark_as_ham!
      end
      undo_with 'update_comment'
      flash[:notice] = 'bold.comment.ham'
      render 'update'
    end

    def mark_spam
      memento undo_template: 'restore_comment' do
        @comment.mark_as_spam!
      end
      flash.now[:notice] = 'bold.comment.spam'
      render 'destroy'
    end

    def destroy
      memento undo_template: 'restore_comment' do
        @comment.destroy
      end
      flash.now[:notice] = 'bold.comment.deleted'
    end

    private

    def set_comment
      @comment = current_site.comments.find params[:id]
    end

    def search_params
      if params[:comment_search].present?
        params[:comment_search].permit :status, :query
      elsif Comment.pending.any?
        { status: 'pending' }
      else
        {}
      end
    end

  end
end