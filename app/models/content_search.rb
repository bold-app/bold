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
class ContentSearch < Search

  attr_accessor :status

  def blank?
    super && status.blank?
  end

  def search(collection)
    collection = super(collection)
    collection = apply_status(collection) if status.present?
    return collection
  end

  def self.status_values
    %i(unpublished published)
  end

  private

  def apply_query(collection)
    super(collection).tap do |scope|
      if status == 'published'
        # restrict search to published contents
        scope.where "#{FulltextIndex.table_name}.published = ?", true
      end
    end
  end

  def apply_status(collection)
    case status
    when 'unpublished'
      collection.draft
    when 'published'
      collection.published
    else
      collection
    end
  end
end