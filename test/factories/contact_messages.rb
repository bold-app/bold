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
  factory :contact_message do
    subject "Hello!"
    body "Lorem Ipsum"
    content { Bold::Site.current.pages.first }
    sender_name { Faker::Name.name }
    sender_email { Faker::Internet.email }
    author_ip { Faker::Internet.ip_v4_address }
    site { Bold::current_site }
  end

end
