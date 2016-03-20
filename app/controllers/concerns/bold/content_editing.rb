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
  module ContentEditing
    extend ActiveSupport::Concern

    included do
      helper 'bold/assets'
      helper 'bold/content_editing'
      decorate_assigned :contents, with: 'Bold::ContentsDecorator'
      decorate_assigned :content, with: 'Bold::ContentDecorator'
      site_object :content
      prepend_before_action :find_content, except: %i(index new create)
    end

    def index
      @content_search = ContentSearch.new content_search_params
      @contents = collection.includes(:draft)
    end

    def show
      @content.load_draft!
      respond_to do |format|
        format.html { index; render 'index' }
        format.js
      end
    end

    def new
      @content = collection.build
    end

    def create
      @content = collection.build
      save_content
    end

    def edit
      @content.load_draft!
    end

    def change_template
    end

    def update_template
      @content.template = params[:content][:template]
      if @content.save_without_draft
        redirect_to edit_url, notice: 'bold.content.template_change_success'
      else
        redirect_to edit_url, notice: 'bold.content.template_change_failure'
      end
    end

    def update
      save_content
    end

    def diff
      original = @content.body
      @content.load_draft!
      draft = @content.body
      if draft != original
        @diff = Diffy::Diff.new(original, draft).to_s(:html)
      end
      render 'bold/content/diff'
    end

    def delete_draft
      memento do
        @content.delete_draft!
      end
      redirect_to edit_url, notice: 'bold.content.draft_deleted'
    end

    def destroy
      if @content.published?
        @content.unpublish
        redirect_to edit_url, notice: t('flash.bold.content.unpublished', title: @content.title)
      else
        @content.delete
        redirect_to( {site_id: current_site.id, action: :index}, notice: t('flash.bold.content.deleted', title: @content.title) )
      end
    end

    private

    def flash_key(base)
      "#{base}#{'_draft' unless publish?}"
    end

    def save_content
      @content.attributes = content_params
      @content.author ||= User.current
      was_published = @content.published?
      has_changes = @content.changed?
      message = if @success = save_or_publish_content
        if (@published && !was_published) || has_changes
          [:notice, flash_key('bold.content.saved')]
        else
          [:info, flash_key('bold.content.no_changes')]
        end
      else
        Rails.logger.error @content.errors.inspect if Rails.env.development?
        [:alert, flash_key('bold.content.not_saved')]
      end
      respond_to do |format|
        format.html do
          flash[message[0]] = message[1]
          if @success
            redirect_to edit_url
          else
            render @content.new_record? ? 'new' : 'edit'
          end
        end
        format.js do
          if params[:go_back].present?
            @back_to = case @content
                       when Post
                         bold_site_posts_url(current_site)
                       when Page
                         bold_site_pages_url(current_site)
                       end
          end
          flash[message[0]] = message[1]
        end
      end
    end

    def save_or_publish_content
      if publish?
        @published = @content.publish!
      else
        @content.save
      end
    end

    def publish?
      params[:publish] || params[:do_publish].present?
    end

  end
end
