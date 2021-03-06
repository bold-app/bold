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

require 'builder'

class RpcPingJob < ActiveJob::Base
  queue_as :default

  def perform(post)
    # we only ping for posts that are published
    if post.is_a?(Post) && post.published?
      Bold.with_site(post.site) do
        Bold::Config.rpc_ping_urls.map{|url| [ url, ping(url, post) ] }
      end
    end
  end

  private

  def ping(url, post)
    r = HTTParty.post url, body: payload(post),
                           headers: { 'Content-Type' => 'application/xml' }
    unless 200 == r.code
      Rails.logger.warn "Ping result from #{url}: #{r.code}\n#{r.body}"
    end
    r.code.to_s
  rescue Exception
    Rails.logger.error "RPC Ping to #{url} failed: #{$!}"
    $!.to_s
  end

  def payload(post)
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.methodCall do
      xml.methodName 'weblogUpdate.ping'
      xml.params do
        xml.param do
          xml.value post.site.name
        end
        xml.param do
          xml.value post.site.external_url
        end
      end
    end
  end

end
