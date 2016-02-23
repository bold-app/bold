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

  validates :site, presence: true
  validates :content, presence: true

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
        # limit also reloads the scope, since we change the processed flag
        # inside the loop this brings up the next batch
        scope.limit(batch_size).each do |log|
          begin
            transaction do
              log.set_device_class!
              if !log.bot? and pv = build_for_log(log, site: site) and !pv.save
                Rails.logger.error "error processing request log #{log.id}: #{pv.errors.inspect}"
              end
              log.update_column :processed, true
            end
          end
        end
      end
    end
  end

  # returns nil if the log's resource isn't present or isn't a Content
  def self.build_for_log(request_log, site: request_log.site)
    if request_log.resource_type == 'Content' and request_log.resource.present?
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

end
