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
module Bold
  module Search

    # Base class for Content and Asset indexers.
    #
    class Indexer

      attr_reader :model_class

      class << self
        private :new

        # sets up the indexer with the given model class
        #
        #   class Asset
        #     Bold::Search::AssetIndexer.setup self
        #   end
        def setup(model)
          the_indexer = new(model)

          model.class_eval do
            has_many :fulltext_indices, as: :searchable, dependent: :delete_all
            after_save do |o|
              the_indexer.update_index o
            end
          end
          model.define_singleton_method :indexer do
            return the_indexer
          end
          model.define_singleton_method :rebuild_index do
            the_indexer.rebuild_index
          end
        end
      end


      def initialize(model_class)
        @model_class = model_class
      end

      # rebuilds the index by wiping out all index records for this type
      def rebuild_index
        FulltextIndex.
          where(site_id: Bold.current_site.id,
                searchable_type: model_class.name).delete_all
        model_class.
          where(site_id: Bold.current_site.id).
          find_in_batches(batch_size: 100) do |group|
          group.each{ |o| do_update_index o }
        end
      end


      # Re-Indexes the given object by deleting all associated index records
      # and building new ones.
      def reindex(object)
        unless ::Bold::Search.indexing_disabled?
          object.fulltext_indices.delete_all
          update_index object
        end
      end


      # Indexes the given object, updating any already existing index records
      # if present, creating new ones otherwise.
      def update_index(object)
        return if ::Bold::Search.indexing_disabled?
        do_update_index object
      end

    end
  end
end