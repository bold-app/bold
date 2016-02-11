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
class RequestLog < ActiveRecord::Base

  USER_AGENT_PARSER = UserAgentParser::Parser.new

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

  belongs_to :site
  belongs_to :resource, polymorphic: true
  belongs_to :permalink
  belongs_to :stats_visit

  attr_accessor :req, :res

  enum device_class: %i(bot mobile desktop)

  before_create :init_from_request_and_response

  scope :humans, ->{ where device_class: [device_classes[:mobile],
                                          device_classes[:desktop]] }
  scope :since, ->(time){ where 'created_at >= ?', time }
  scope :before, ->(time){ where 'created_at < ?', time }

  # RequestLog.for_last(7.days)
  scope :for_last, ->(timespan){
    upper = Time.zone.now.beginning_of_day
    lower = upper - timespan
    since(lower).before(upper)
  }

  def bot?
    device_class == 'bot'
  end

  def set_device_class!
    if device_class.nil?
      self.device_class = self.class.determine_device_class(request['user_agent'], request['language'])
      save
    end
  end

  private

  def init_from_request_and_response

    if req
      self.secure   = req.ssl?
      self.hostname = req.host
      self.path     = req.fullpath
      self.request['user_agent'] = req.user_agent
      self.request['language'] = req.headers['HTTP_ACCEPT_LANGUAGE']
      self.request['referrer'] = req.referrer
      self.request['remote_ip']  = req.remote_ip
    end

    if res
      self.status   = res.status
      self.response['disposition']  = res.headers['Content-Disposition']
      self.response['content_type'] = res.content_type
    end
  end

  # sg-Orbiter/1.0 (+http://searchgears.de/uber-uns/crawling-faq.html)
  #
  def self.determine_device_class(user_agent, language)
    # 'real' clients always have user agent and accept-language headers
    return :bot if user_agent.blank? || language.blank?
    ua = USER_AGENT_PARSER.parse(user_agent)
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

end