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
# capybara setup
#
# use screenshot_and_save_page in integration tests to capture the current
# page. screenshot saving only works with poltergeist, the default driver just
# saves the html.

require 'capybara/rails'
require 'capybara/poltergeist'

# makes poltergeist integration tests with varyig domains work: (need to add any test domains to etc/hosts as well, pointing to localhost)
Capybara.always_include_port = true

# http://docs.travis-ci.com/user/common-build-problems/
TIMEOUT = ENV['TRAVIS'] ? 10 : 3
Capybara.default_max_wait_time = TIMEOUT
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, timeout: TIMEOUT)
end

Capybara.javascript_driver = :poltergeist


require 'capybara-screenshot/minitest'
Capybara::Screenshot.register_filename_prefix_formatter(:minitest) do |fault|
  fault.location.first.match(/^test\/integration\/(.+:\d+)/)[1].gsub /[^\w]/, '_'
end
`rm -fr #{Rails.root.join 'tmp/capybara'}/*`
