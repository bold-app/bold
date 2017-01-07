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
class Bold::Settings::TagsController < Bold::SettingsController
  helper 'bold/settings'

  prepend_before_action :find_tag, only: %i(edit update destroy)
  site_object :tag

  def index
    @tags = current_site.tags.page(params[:page]).per(20)
  end

  def edit
  end

  def update
    r = UpdateTag.call @tag, tag_params
    if r.tag_updated?
      redirect_to bold_site_settings_tags_path(current_site)
    else
      render 'edit'
    end
  end

  def destroy
    DeleteTag.call @tag
    redirect_to bold_site_settings_tags_path(current_site), notice: 'bold.tag.deleted'
  end


  private

  def find_tag
    @tag = Tag.find params[:id]
  end

  def tag_params
    params.require(:tag).permit :name, :slug
  end

end

