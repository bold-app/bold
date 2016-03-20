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
class SiteUser < ActiveRecord::Base
  belongs_to :site
  belongs_to :user

  validates :site, presence: true
  validates :user, presence: true

  scope :by_name, ->{ includes(:site).order "#{Site.table_name}.name ASC" }

  ROLES = %i(editor manager)

  def role
    manager? ? :manager : :editor
  end

  def site_values
    connected_site_ids = user.site_users.map{|su| su.site_id unless su == self}.compact
    sites = Site.all
    sites = sites.where('id NOT IN (?)', connected_site_ids) if connected_site_ids.any?
    sites.map{|s| [s.name, s.id]}
  end
end
