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

require 'akismet/client'

# Base class for comments and contact form messages
class VisitorPosting < SiteRecord

  belongs_to :content, required: true

  before_validation :strip_tags!, on: :create
  before_validation :init_status, on: :create

  scope :existing, ->{ where deleted_at: nil }
  scope :ordered, ->{ order('created_at DESC') }

  memento_changes :update

  enum status: { pending: 0, approved: 1, spam: 2 }
  def init_status
    self.status ||= :pending
  end

  def content=(obj)
    self.site = obj.site
    super
  end


  def strip_tags!
    sanitizer = Rails::Html::FullSanitizer.new
    unsafe_attributes.each do |attr|
      send "#{attr}=", sanitizer.sanitize(send(attr).to_s)
    end
  end


  # override if necessary to do anything else
  def approve!
    approved!
  end

  def set_request(req)
    self.author_ip = req.remote_ip
    self.request['user_agent'] = req.user_agent
    self.request['referrer'] = req.referrer
    ::Bold::AkismetArgs::AKISMET_ENV.each do |var|
      self.request[var] = req.env[var]
    end
  end

  def to_s
    "#{type} from #{author_ip}\n#{data.to_a.map{|a| "#{a[0]}: #{a[1]}"}} "
  end


  private

  # override in case you do *not* want to have all html stripped from all
  # DATA_ATTRIBUTES
  def unsafe_attributes
    data.keys
  end


  def additional_akismet_attributes
    {}
  end

end
