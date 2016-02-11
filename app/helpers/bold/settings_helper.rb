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
  module SettingsHelper
    def render_extension_config(extension, args = {})
      if extension.configurable?
        begin
          return render args.merge(partial: extension.settings_partial)
        rescue ActionView::MissingTemplate
        end
      end
      return content_tag(:p, I18n.t('bold.extensions.no_config'))
    end

    def pages_for(usage)
      @site.pages.published.order('title ASC').select do |page|
        ::Bold::Template::USAGE_KEYS[usage].include? page.get_template.usage
      end
    end
  end
end