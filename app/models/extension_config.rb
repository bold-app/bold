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
class ExtensionConfig < ActiveRecord::Base
  belongs_to :site
  validates :name, presence: true

  scope :themes,  ->{ where type: 'ThemeConfig'}
  scope :plugins, ->{ where type: 'PluginConfig'}

  before_create :set_defaults

  CONFIG_MATCHER = /\Aconfig\[(.+?)\](=)?\z/
  def method_missing(method, *args)
    if method.to_s =~ CONFIG_MATCHER
      attribute = $1
      if $2
        config[attribute] = args.shift
      else
        config[attribute]
      end
    else
      super
    end
  end

  def config=(cfg)
    if cfg
      cfg.stringify_keys!
      config.update cfg
    else
      config.clear
    end
  end

  def respond_to?(method, *args)
    method.to_s.match(CONFIG_MATCHER) or super
  end

  private
  # implemented in sub classes
  def defaults; {} end

  def set_defaults
    defaults.each do |key, value|
      config[key.to_s] = value
    end
  end

end
