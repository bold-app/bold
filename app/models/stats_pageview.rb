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
class StatsPageview < ActiveRecord::Base
  belongs_to :site
  belongs_to :stats_visit, counter_cache: :length
  belongs_to :request_log
  belongs_to :content

  attr_accessor :visitor_id, :timestamp

  before_create do
    self.date     ||= timestamp.to_date
  end

  scope :since, ->(date){ where 'date >= ?', date }
  scope :until, ->(date){ where 'date <= ?', date }

  def self.build_pageviews(site)
    site.in_time_zone do
      scope = site.request_logs.
        where(processed: false, resource_type: 'Content').
        order('created_at ASC')
      batch_size = 1000
      num_records = scope.count
      (num_records / batch_size + 1).times do
        transaction do
          # limit also reloads the scope, since we change the processed flag
          # inside the loop this brings up the next batch
          scope.limit(batch_size).each do |log|
            log.set_device_class!
            build_for_log(log, site: site).save! unless log.bot?
            log.update_column :processed, true
          end
        end
      end
    end
  end

  def self.build_for_log(request_log, site: request_log.site)
    return nil unless request_log.resource_type == 'Content'
    visit = StatsVisit.find_or_create_for_log(request_log)
    new(
      site: site,
      visitor_id: request_log.visitor_id,
      timestamp: request_log.created_at,
      content_id: request_log.resource_id,
      request_log: request_log,
      stats_visit: visit
    )
  end

end
