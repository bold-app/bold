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
class Invitation
  include ActiveModel::Model

  attr_accessor :email, :role, :site_id

  validates :site_id, presence: true
  validates :email, presence: true, format: Devise.email_regexp
  validates :role, presence: true, inclusion: SiteUser::ROLES.map(&:to_s)

  def role_values
    SiteUser::ROLES.map{|r| [I18n.t("bold.common.roles.#{r}"), r]}
  end

  def site_values
    Site.all.by_name.map{|s| [s.name, s.id]}
  end

  def create
    return false unless valid?
    site = Site.find site_id
    if user = User.invite!({email: email}, Bold::current_user)
      site_user = user.site_users.build site_id: site.id, manager: (role == 'manager')
      site_user.save
    end
  end

  def valid?
    self.site_id = Site.current.id if site_id.blank?
    super
  end
end