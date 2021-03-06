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
class Bold::Settings::CategoriesController < Bold::SettingsController
  helper 'bold/settings'

  prepend_before_action :find_category, only: %i(edit update destroy)
  site_object :category

  def index
    @categories = current_site.categories
  end

  def edit
  end

  def update
    r = UpdateCategory.call @category, category_params
    if r.category_updated?
      redirect_to bold_site_settings_categories_path(current_site)
    else
      render 'edit'
    end
  end

  def new
    @category = Category.new
  end

  def create
    r = CreateCategory.call(category_params)
    if r.category_created?
      redirect_to bold_site_settings_categories_path(current_site)
    else
      @category = r.category
      render 'new'
    end
  end

  def destroy
    memento(undo_template: 'restore_category') { @category.destroy }
    redirect_to bold_site_settings_categories_path(current_site), notice: 'bold.category.deleted'
  end


  private

  def find_category
    @category = Category.find params[:id]
  end

  def category_params
    params.require(:category).permit :name, :slug, :asset_id, :description
  end

end
