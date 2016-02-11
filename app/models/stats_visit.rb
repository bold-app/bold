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
class StatsVisit < ActiveRecord::Base

  # maximum distance between pageviews to be considered the same visit
  MAXIMUM_GAP = 30.minutes

  belongs_to :site

  has_many :stats_pageviews

  before_create do
    self.date     ||= started_at.to_date
    self.ended_at ||= started_at
  end

  scope :since, ->(date){ where 'date >= ?', date }
  scope :until, ->(date){ where 'date <= ?', date }

  def can_include?(time)
    time <= ended_at + MAXIMUM_GAP
  end

  def append(request_log)
    update_attribute :ended_at, request_log.created_at
  end


  def self.find_or_create_for_log(request_log)
    if (visitor_id = request_log.visitor_id).present?
      last_visit = StatsVisit.where(site_id: request_log.site_id,
                                    visitor_id: visitor_id).first
      if last_visit && last_visit.can_include?(request_log.created_at)
        last_visit.append(request_log)
        last_visit
      else
        new(
          site: request_log.site,
          visitor_id: request_log.visitor_id,
          mobile: (request_log.device_class == 'mobile'),
          started_at: request_log.created_at
        ).tap(&:save!)
      end
    end
  end

end