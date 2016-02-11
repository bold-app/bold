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
require 'bold/version'

module Bold
  module_function

  def current_user
    RequestStore.store[:bold_user]
  end
  def current_user=(u)
    RequestStore.store[:bold_user] = u
  end

  def current_site
    RequestStore.store[:bold_site]
  end
  def current_site=(s)
    RequestStore.store[:bold_site] = s
  end

  # executes a block in the context of the given site, by default also setting
  # the timezone to the sites zone.
  def with_site(site, switch_timezone: true)
    old_site = Bold::current_site
    begin
      Bold::current_site = site
      if switch_timezone
        Time.use_zone site.time_zone do
          yield
        end
      else
        yield
      end
    ensure
      Bold::current_site = old_site
    end
  end

  def application_url
    'https://bold-app.org/'
  end

  def application_name
    'Bold'
  end

  def version
    Bold::VERSION
  end
end

require "bold/errors"
require "bold/patches/draper"
require "bold/patches/delayed_job"
require "bold/patches/string"

Bold::Kramdown.setup