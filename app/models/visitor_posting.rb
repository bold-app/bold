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
class VisitorPosting < ActiveRecord::Base
  include Spamcheck
  include Deletable

  belongs_to :site,    required: true, inverse_of: :visitor_postings
  belongs_to :content, required: true

  before_validation :strip_tags!, on: :create
  before_validation :init_status, on: :create

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

  # Manually mark a posting as 'Not Spam'.
  # To allow proper undo we wait an hour before doing the actual Akismet update.
  # Undo will then restore the old state and remove the pending job.
  def mark_as_ham!
    pending!
    report_ham!
  end

  # Manually mark the posting as Spam.
  # To allow proper undo we wait an hour before doing the actual Akismet update.
  # Undo will then restore the comment and remove the pending job.
  def mark_as_spam!
    report_spam!
    self.delete
  end

  def spam_check!
    spam_level = run_akismet_check
    self.spam! unless :ham == spam_level
    return spam_level
  end

  def run_akismet_check
    if akismet_possible?
      is_spam, is_blatant = Akismet::Client.open(*akismet_config) do |client|
        client.check(*akismet_args)
      end
      is_blatant ? :blatant : (is_spam ? :spam : :ham)
    else
      :ham
    end
  end

  def set_request(req)
    self.author_ip = req.remote_ip
    self.request['user_agent'] = req.user_agent
    self.request['referrer'] = req.referrer
    AKISMET_ENV.each do |var|
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

  def report_ham!
    enqueue_akismet_job :ham
  end

  def report_spam!
    enqueue_akismet_job :spam
  end


  def enqueue_akismet_job(method, wait = 1.hour)
    if akismet_possible?
      AkismetUpdateJob.
        set(wait: wait).
        perform_later method.to_s, akismet_config, akismet_args
    end
  end

  AKISMET_ENV = %w(
    HTTP_ACCEPT
    HTTP_ACCEPT_CHARSET
    HTTP_ACCEPT_ENCODING
    HTTP_ACCEPT_LANGUAGE
    HTTP_HOST
  )

  def akismet_args
    [
      author_ip.to_s,
      request['user_agent'],
      {
        created_at: created_at.iso8601,
        env: request.slice(*AKISMET_ENV),
        referrer: request['referrer'],
        test: !Rails.env.production?,
      }.merge(additional_akismet_attributes)
    ]
  end

  def additional_akismet_attributes
    {}
  end

  def akismet_config
    [
      site.akismet_key,
      site.external_url,
      {
        app_name: Bold.application_name,
        app_version: Bold.version
      }
    ]
  end

  def akismet_possible?
    site.akismet_key.present?
  end

  def take_current_site
    self.site_id ||= content&.site_id
  end
end
