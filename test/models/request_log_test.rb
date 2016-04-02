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
require 'test_helper'
require "benchmark"

class RequestLogTest < ActiveSupport::TestCase

  class MockRequest < Struct.new(:user_agent, :language)
    def headers
      {'HTTP_ACCEPT_LANGUAGE' => language}
    end
    def ssl?; true end
    def host; 'test.host' end
    def fullpath; '/' end
    def referrer; '' end
    def remote_ip; '127.0.0.1' end
  end

  setup do
    Bold::current_site = @site = create :site, theme_name: 'test'
  end

  test 'should set device class' do
    req = MockRequest.new 'Mozilla/5.0 (Android; Mobile; rv:38.0) Gecko/38.0 Firefox/38.0)', 'de-DE,en-US;q=0.7,en;q=0.3'
    log = create :request_log, site: @site, req: req, device_class: nil
    assert_nil log.device_class
    log.set_device_class!
    assert_equal 'mobile', log.device_class
  end

end
