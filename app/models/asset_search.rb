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
class AssetSearch < Search

  attr_accessor :content_type

  def blank?
    super && content_type.blank?
  end

  def search(collection)
    collection = super(collection)
    collection = apply_content_type(collection) if content_type.present?
    return collection
  end

  def self.content_type_values
    Site.current.assets.pluck('distinct content_type')
  end

  private

  def apply_content_type(collection)
    collection.where content_type: content_type
  end

end