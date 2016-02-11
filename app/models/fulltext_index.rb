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
#
# FulltextIndex.search('foo') (implies .includes(:searchable))
#
# Content.search('foo') ->
# Content.includes(:fulltext_index).where(fulltext_indices.tsv @@ plainto_tsquery('foo'))
#
class FulltextIndex < ActiveRecord::Base

  belongs_to :searchable, polymorphic: true, required: true
  before_validation :set_default_config
  after_save :create_tsv

  before_create do |r|
    r.site_id = Bold::current_site.id
  end

  # map weight identifiers (a-d) to textual content
  #
  #     {
  #       a: 'title lorem important',
  #       b: 'body text less weight'
  #     }
  attr_accessor :data

  WEIGHTS = %w(A B C D)
  CONFIG = "coalesce(:config, 'pg_catalog.english')::regconfig"
  SET_WEIGHT = "setweight(to_tsvector(#{CONFIG}, :text), :weight)"

  scope :published, ->{ where published: true }
  scope :search, ->(q){ where "plainto_tsquery(#{CONFIG}, :query) @@ tsv",
    config: Site.current.tsearch_config, query: q}


  private

  def set_default_config
    self.config = Site.current.try :tsearch_config if config.blank?
  end

  def create_tsv
    self.data ||= searchable.try(:data_for_index)
    return unless data
    tsvector = data.map do |weight, value|
      weight = weight.to_s.upcase
      raise "illegal weight key #{weight}" unless WEIGHTS.include?(weight)
      if Enumerable === value
        value = value.flatten.compact.join(' ')
      end

      self.class.send :sanitize_sql_array,
        [SET_WEIGHT, {config: config, text: value.to_s, weight: weight}]
    end.join(' || ')
    self.class.connection.execute <<-SQL
      update #{self.class.table_name} set tsv = #{tsvector} where id = '#{id}'
    SQL
  end

end