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
class ThemeConfig < ExtensionConfig

  before_create :set_defaults

  DEFAULT_ATTRIBUTES = %i(
    default_page_template
    default_post_template
  )

  DEFAULT_ATTRIBUTES.each do |attribute|
    store_accessor :config, attribute
  end

  def configured?
    not DEFAULT_ATTRIBUTES.any?{|attrib| send(attrib).blank?}
  end

  def theme_name; name end

  private

  def set_defaults
    super
    if theme = Bold::Theme[theme_name]
      self.default_post_template ||= theme.find_template(:post, :default).try :name
      self.default_page_template ||= theme.find_template(:page, :default).try :name
    end
  end

  def defaults
    theme.default_settings
  end

  def theme
    Bold::Theme[name] or raise ActiveRecord::RecordNotFound
  end

end