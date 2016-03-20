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
class Search
  include ActiveModel::Model
  attr_accessor :query

  def normalize!
    self.query = query.to_s.strip
  end

  def blank?
    !query.present?
  end

  def search(collection)
    collection = apply_query(collection) if query.present?
    return collection
  end

  private

  def ts_config
    Site.current.tsearch_config
  end

  def apply_query(collection)
    normalize!
    collection.
      joins(:fulltext_indices).
      where("#{FulltextIndex.table_name}.tsv @@ plainto_tsquery(#{FulltextIndex::CONFIG}, :query)", config: ts_config, query: query)
  end
end
