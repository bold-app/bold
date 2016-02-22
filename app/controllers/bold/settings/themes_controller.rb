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
class Bold::Settings::ThemesController < Bold::SettingsController
  skip_before_action :check_site_config
  before_action :check_for_current_theme, only: %i(edit update)

  helper 'bold/settings'

  decorate_assigned :themes, with: 'Bold::ExtensionDecorator'

  def index
    @themes = Bold::Theme.all_themes
  end

  def enable
    @theme = find_theme
    current_site.enable_theme!(@theme.id)
    redirect_to edit_bold_settings_theme_path(@theme.id),
      notice: I18n.t('flash.bold.theme_changed', name: @theme.name)
  end

  def edit
    @theme = find_theme
    find_theme_config
  end

  def update
    find_theme_config
    @theme_config.config.update theme_config_params
    if @theme_config.save
      redirect_to bold_settings_themes_path, notice: :saved
    else
      render 'edit'
    end
  end

  private

  def check_for_current_theme
    raise Bold::ThemeNotFound unless params[:id] == current_site.theme_name
  end

  def find_theme
    Bold::Theme[params[:id]]
  end

  def theme_config_params
    params[:theme_config].permit(
      :default_page_template, :default_post_template
    ).to_h.tap do |p|
      if params[:theme_config][:config]
        p.update params[:theme_config][:config].to_unsafe_hash
      end
    end
  end

  def find_theme_config
    @theme_config = current_site.theme_config
    @templates = current_site.theme.templates.values
  end

end
