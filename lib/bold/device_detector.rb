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
  class DeviceDetector

    # cache borrowed from the device_detector library (LGPLv3)
    # https://github.com/podigee/device_detector
    class MemoryCache

      DEFAULT_MAX_KEYS = 5000

      attr_reader :data, :max_keys

      def initialize(max_cache_keys: DEFAULT_MAX_KEYS)
        @data = {}
        @max_keys = max_cache_keys
        @lock = Mutex.new
      end

      def set(key, value)
        lock.synchronize do
          purge_cache
          data[String(key)] = value
        end
      end

      def get(key)
        data[String(key)]
      end

      def key?(string_key)
        data.key?(string_key)
      end

      def get_or_set(key, value = nil)
        string_key = String(key)

        if key?(string_key)
          get(string_key)
        else
          value = yield if block_given?
          set(string_key, value)
        end
      end

      private

      attr_reader :lock

      def purge_cache
        key_size = data.size

        if key_size >= max_keys
          # always remove about 1/3 of keys to reduce garbage collecting
          amount_of_keys = key_size / 3

          data.keys.first(amount_of_keys).each { |key| data.delete(key) }
        end
      end

    end

    @@cache = MemoryCache.new
    cattr_accessor :cache

    def initialize(user_agent, language)
      @user_agent = user_agent
      @language = language
    end

    def device_class
      # shortcut: 'real' clients always have user agent and accept-language
      # headers. everything else is considered a bot.
      if @user_agent.blank? || @language.blank?
        :bot
      else
        cache.get_or_set(@user_agent) do
          determine_device_class
        end
      end
    end

    private

    def determine_device_class
      :desktop
    end

  end

  # device detection based on the user_agent_parser gem.
  # raw performance is poor compared to browser or device_detector, but it's
  # most exact.
  module UserAgentParser
    # common mobile OSes
    MOBILE_OS = [
      'Android',
      'BlackBerry OS',
      'iOS',
      'Symbian OS',
      'Windows Phone',
    ]

    # esoteric devices which are not detected by OS
    MOBILE_DEVICES = [
      'Palm Source',
      'Generic Smartphone',
    ]

    # some mobile browsers have user agent strings which do not
    # lead to mobile os / device detection
    MOBILE_BROWSERS = [
      'Opera Mini',
      'Opera Mobile'
    ]

    def parser
      @@parser ||= ::UserAgentParser::Parser.new
    end

    def determine_device_class

      ua = parser.parse(@user_agent)
      device = ua.device.family
      if device == 'Spider'
       :bot
      elsif MOBILE_OS.include?(ua.os.name) ||
        MOBILE_DEVICES.include?(device) ||
        MOBILE_BROWSERS.include?(ua.name)
        :mobile
      else
        :desktop
      end
    end
    private :determine_device_class

  end


  # device detection based on the browser gem
  # fast but not very accurate with bot detection
  module Browser

    def determine_device_class
      browser = ::Browser.new(@user_agent, accept_language: @language)
      if browser.bot?
        :bot
      elsif browser.device.mobile? || browser.device.tablet?
        :mobile
      else
        :desktop
      end
    end
    private :determine_device_class

  end

  # device detection based on the device_detector gem
  # fast but not very accurate with bot detection
  module PodigeeDeviceDetector
    PORTABLES = [
      'smartphone',
      'tablet',
      'portable media player',
      'car browser',
      'camera'
    ]

    MOBILE_BROWSERS = [
      'Opera Mini',
      'Opera Mobile'
    ]
    def determine_device_class
      client = ::DeviceDetector.new(@user_agent)
      if client.bot?
        :bot
      elsif PORTABLES.include?(client.device_type) || MOBILE_BROWSERS.include?(client.name)
        :mobile
      else
        :desktop
      end
    end
    private :determine_device_class

  end

end


if defined?(::UserAgentParser)
  Bold::DeviceDetector.prepend Bold::UserAgentParser
elsif defined?(::Browser)
  Bold::DeviceDetector.prepend Bold::Browser
elsif defined?(::DeviceDetector)
  Bold::DeviceDetector.prepend Bold::PodigeeDeviceDetector
end
