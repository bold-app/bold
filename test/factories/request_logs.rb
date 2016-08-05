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
FactoryGirl.define do
  factory :request_log do
    status 200
    secure false
    hostname "test.host"
    path "/2015/01/some-post"
    site { Site.current }
    resource { FactoryGirl.create :page }
    permalink { FactoryGirl.create :permalink }
    visitor_id { SecureRandom.uuid }
    device_class 2

    factory :bot_request do
      device_class 0
    end
    factory :mobile_request do
      device_class 1
    end
  end

end
