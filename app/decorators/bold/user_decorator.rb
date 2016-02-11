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
class Bold::UserDecorator < Draper::Decorator
  decorates User
  delegate_all

  def last_sign_in_at
    date = object.current_sign_in_at || object.last_sign_in_at
    h.distance_of_time_in_words_to_now date rescue nil
  end

  def invited_at
    if d = invitation_sent_at and invitation_accepted_at.blank?
      h.distance_of_time_in_words_to_now d
    end
  end

  def invited_by
    User.find_by_id(invited_by_id).try :email
  end

  def role_name(site = Site.current)
    I18n.t "bold.common.roles.#{role site}"
  end

  def name_and_email
    name.blank? ? email : "#{name} (#{email})"
  end

  def site_users
    Bold::SiteUserDecorator.decorate_collection object.site_users.by_name
  end

end