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
class Category < ActiveRecord::Base
  include SiteModel
  prepend HasPermalink
  prepend HasSlug

  has_many :posts, dependent: :nullify
  belongs_to :asset

  memento_changes :destroy

  validates :name,
    presence: true,
    length: { maximum: 100 },
    uniqueness: { scope: :site_id, case_sensitive: false }

  def name=(new_name)
    self.slug = new_name if slug.blank?
    super
  end

end
