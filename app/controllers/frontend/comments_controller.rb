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
class Frontend::CommentsController < FrontendController

  def create
    @content = find_content
    @comment = @content.comment! comment_params, request
    if @comment.persisted?
      notice = if current_site.auto_approve_comments?
                 Bold::I18n.t('flash.comments.created_appears_soon')
               else
                 Bold::I18n.t('flash.comments.created_awaits_moderation')
               end
      redirect_to content_url(@content.path), notice: notice
    else
      render_content
    end
  end

  private

  def comment_params
    if p = params[:comment]
      p.permit :author_name, :author_email, :author_website, :body
    end
  end

end
