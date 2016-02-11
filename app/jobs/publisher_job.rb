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
# Publishes a post if its post_date is reached.
#
class PublisherJob < ActiveJob::Base
  queue_as :default

  def perform(post)
    Bold::with_site(post.site) do
      if post.scheduled?
        if post.post_date <= Time.zone.now
          post.publish!
        else
          self.class.set(wait_until: post.post_date).perform_later(post)
        end
      end
    end
  end


end