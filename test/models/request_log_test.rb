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

  MOBILE = [
    'Mozilla/5.0 (Android; Mobile; rv:38.0) Gecko/38.0 Firefox/38.0)',
    'Mozilla/5.0 (Linux; U; Android 4.0.2; en-us; Galaxy Nexus Build/ICL53F) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
    'Mozilla/4.0 (compatible; MSIE 6.0; Windows 95; PalmSource; Blazer 3.0) 16; 160x160',
    'Opera/9.80 (J2ME/MIDP; Opera Mini/9.80 (S60; SymbOS; Opera Mobi/23.348; U; en) Presto/2.5.25 Version/10.54',
    'Opera/9.80 (J2ME/MIDP; Opera Mini/9.80 (J2ME/23.377; U; en) Presto/2.5.25 Version/10.54',
    'Opera/9.80 (Android; Opera Mini/7.6.35766/35.5706; U; en) Presto/2.8.119 Version/11.10',
    'Mozilla/5.0 (BlackBerry; U; BlackBerry 9900; en) AppleWebKit/534.11+ (KHTML, like Gecko) Version/7.1.0.346 Mobile Safari/534.11+',
    'Mozilla/5.0 (iPad; CPU OS 8_3 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12F69 Safari/600.1.4',
    'Mozilla/5.0 (Mobile; Windows Phone 8.1; Android 4.0; ARM; Trident/7.0; Touch; rv:11.0; IEMobile/11.0; NOKIA; Lumia 920)'
  ]

  BOTS = [
    'Pingdom.com_bot_version_1.4_(http://www.pingdom.com/)',
    'Mozilla/5.0 (compatible; Baiduspider/2.0; +http://www.baidu.com/search/spider.html)',
    'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
    'sg-Orbiter/1.0 (+http://searchgears.de/uber-uns/crawling-faq.html)',
  ]

  DESKTOP = [
    'Mozilla/5.0 (X11; Linux x86_64; rv:38.0) Gecko/20100101 Firefox/38.0)',
    'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; .NET CLR 3.0.04506; .NET CLR 3.5.21022; InfoPath.2; BitTitan)',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36',
  ]

  setup do
    @site = create :site, theme_name: 'test'
    @lang = 'de-DE,en-US;q=0.7,en;q=0.3'
  end

  test 'should set device class' do
    log = create :request_log, site: @site, req: MockRequest.new(MOBILE[0], @lang), device_class: nil
    assert_nil log.device_class
    log.set_device_class!
    assert_equal 'mobile', log.device_class
  end

  test "should recognize mobile browsers" do
    MOBILE.each do |ua|
      assert_equal :mobile, RequestLog.determine_device_class(ua, @lang)
    end
  end

  test "should recognize bots by UA" do
    BOTS.each do |ua|
      assert_equal :bot, RequestLog.determine_device_class(ua, @lang)
    end
  end

  test 'should recognize as bot if no language' do
    MOBILE.each do |ua|
      assert_equal :bot, RequestLog.determine_device_class(ua, '')
    end
    DESKTOP.each do |ua|
      assert_equal :bot, RequestLog.determine_device_class(ua, '')
    end
  end

  test "should recognize desktop browsers" do
    DESKTOP.each do |ua|
      assert_equal :desktop, RequestLog.determine_device_class(ua, @lang)
    end
  end


end