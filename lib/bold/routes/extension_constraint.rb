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
  module Routes

    # Instances of this class are used to limit routes installed by plugins and
    # themes to those sites where the plugin / theme is active.
    # see Extension::install_routes!
    class ExtensionConstraint

      def initialize(extension)
        @extension = extension
      end

      def matches?(request)
        if site = Site.for_hostname(request.host)
          case @extension
          when Plugin
            site.plugin_enabled? @extension.id.to_s
          when Theme
            site.theme_name == @extension.id.to_s
          else
            false
          end
        else
          false
        end
      end

    end

  end
end