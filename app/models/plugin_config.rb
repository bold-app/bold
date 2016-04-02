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
class PluginConfig < ExtensionConfig

  store_accessor :config, :enabled

  def enabled?; '1' == enabled end

  def enable!
    self.enabled = '1'
    save validate: false
  end

  def disable!
    self.enabled = '0'
    save validate: false
  end

  def plugin
    Bold::Plugin[name] or raise ActiveRecord::RecordNotFound
  end

  private

  def defaults
    { enabled: '0' }.merge plugin.default_settings
  end

end
