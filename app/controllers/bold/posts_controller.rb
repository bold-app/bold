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
module Bold
  class PostsController < SiteController
    include ContentEditing
    helper "bold/activity/comments"

    def index
      super
      @contents = @contents.page(params[:page]).per(20).includes(:tags)
    end

    def update
      save_post
    end

    def create
      @content = current_site.posts.build
      save_post
    end


    private

    def save_post
      @content.attributes = content_params
      result = SaveContent.call(
        @content,
        publish: (params[:publish] || params[:do_publish].present?)
      )
      flash[result.message_severity] = result.message

      respond_to do |format|

        format.html do
          if result.saved?
            redirect_to edit_bold_post_path @content
          else
            render @content.new_record? ? 'new' : 'edit'
          end
        end

        format.js do
          if params[:go_back].present?
            @back_to = bold_site_posts_url(current_site)
          end
        end
      end
    end

    def find_content
      @content = Post.alive.find params[:id]
    end

    def edit_url(content = @content)
      edit_bold_post_path(content)
    end

    def collection
      coll = current_site.posts.alive.order('contents.post_date DESC, contents.created_at DESC')
      @content_search.present? ? @content_search.search(coll) : coll
    end

    def content_params
      params.require(:content).permit(:title, :body, :category_id, :slug, :post_date_str, :template, :tag_list, :meta_title, :meta_description, template_field_values: @content.get_template.fields)
    end

    def content_search_params
      params[:content_search].permit :status, :query, :category if params[:content_search]
    end

  end
end
