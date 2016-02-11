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
class Bold::Settings::PluginsController < Bold::SettingsController

  helper 'bold/settings'

  decorate_assigned :plugins, with: 'Bold::ExtensionDecorator'
  def index
    @plugins = Bold::Plugin.all.values.sort{ |a,b| a.name.downcase <=> b.name.downcase }
  end

  def edit
    @plugin = find_plugin
    @plugin_config = find_plugin_config
  end

  def update
    @plugin_config = find_plugin_config
    @plugin_config.config.update plugin_params[:config]
    if @plugin_config.save
      redirect_to bold_settings_plugins_path
    else
      render 'edit'
    end
  end

  def enable
    @plugin = find_plugin
    current_site.enable_plugin!(@plugin.id)
    redirect_to edit_bold_settings_plugin_path(@plugin.id),
      notice: I18n.t('flash.bold.plugin.enabled', name: @plugin.name)
  end

  def destroy
    @plugin = find_plugin
    current_site.disable_plugin! @plugin.id
    redirect_to bold_settings_plugins_path,
      alert: I18n.t('flash.bold.plugin.disabled', name: @plugin.name)
  end

  private

  def find_plugin
    Bold::Plugin[params[:id]]
  end

  def find_plugin_config
    current_site.plugin_config params[:id]
  end

  def plugin_params
    if params[:plugin_config]
      params[:plugin_config].permit config: params[:plugin_config][:config].try(:keys)
    else
      { config: {} }
    end
  end
end