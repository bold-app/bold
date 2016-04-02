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

  # Plugin class.
  #
  # Plugins can be activated and configured for each site separately.
  #
  class Plugin < Extension

    # installs a view hook which will only be rendered if the plugin is active
    # on the current site
    def render_on(hook, template)
      super hook, template, if: ->(context){ Site.current.plugin_enabled?(id) }
    end

    # override to dynamically add some css class(es) to the content's body tag
    def content_class(content = nil, &block)
      if block_given?
        @content_class = block
      else
        @content_class.call content.site, content.site.plugin_config(id), content
      end
    end

    def to_param; id end


    class << self
      def [](name)
        super or raise PluginNotFound.new("plugin >#{name}< does not exist")
      end
    end

  end
end
