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

module Spamcheck
  extend ActiveSupport::Concern
  include SiteModel

  def spam_check!
    spam_level = run_akismet_check
    self.spam! unless :ham == spam_level
    return spam_level
  end

  def report_ham!
    enqueue_akismet_job :ham
  end

  def report_spam!
    enqueue_akismet_job :spam
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

  def enqueue_akismet_job(method, wait = 1.hour)
    if akismet_possible?
      CommentAkismetUpdateJob.
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
        author: author_name,
        author_email: author_email,
        author_url: author_website,
        created_at: created_at.iso8601,
        env: request.slice(*AKISMET_ENV),
        post_url: post.public_url,
        post_modified_at: post.post_date.iso8601,
        referrer: request['referrer'],
        test: !Rails.env.production?,
        text: body,
        type: 'comment',
      }
    ]
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


end