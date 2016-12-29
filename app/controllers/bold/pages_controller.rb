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
  class PagesController < SiteController
    include ContentEditing

    def update
      save_page
    end

    def create
      @content = current_site.pages.build
      save_page
    end

    private

    def save_page
      @content.attributes = content_params
      result = SaveContent.call(
        @content,
        publish: (params[:publish] || params[:do_publish].present?)
      )
      flash[result.message_severity] = result.message

      respond_to do |format|

        format.html do
          if result.saved?
            redirect_to edit_bold_page_path @content
          else
            render @content.new_record? ? 'new' : 'edit'
          end
        end

        format.js do
          if params[:go_back].present?
            @back_to = bold_site_pages_url(current_site)
          end
        end
      end
    end

    def edit_url(content = @content)
      edit_bold_page_path(content)
    end

    def find_content
      @content = Page.existing.find params[:id]
    end

    def collection
      coll = current_site.pages.existing.order('slug ASC')
      @content_search.present? ? @content_search.search(coll) : coll
    end

    def content_params
      params.require(:content).permit(:title, :body, :slug, :post_date_str, :template, :meta_title, :meta_description, template_field_values: @content.get_template.fields)
    end

    def content_search_params
      params[:content_search].permit :status, :query if params[:content_search]
    end

  end
end
