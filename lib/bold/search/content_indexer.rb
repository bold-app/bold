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
    class ContentIndexer < Indexer

      private

      def do_update_index(content)
        return unless content.fulltext_searchable?
        indices = content.fulltext_indices

        # public index
        if content.published?
          idx = indices.where(published: true).first_or_initialize(site_id: content.site_id)
          idx.data = data_for_index content
          idx.save
        else
          indices.where(published: true).delete_all
        end

        # non published content
        if content.draft? || content.has_draft?
          idx = indices.where(published: false).first_or_initialize(site_id: content.site_id)
          idx.data = if content.has_draft?
            drafted_content = model_class.find(content.id)
            drafted_content.load_draft!
            data_for_index drafted_content
          else
            data_for_index content
          end
          idx.save
        else
          indices.where(published: false).delete_all
        end
      end

      def data_for_index(content)
        tags = content.tag_list
        if content.respond_to?(:category) && cat = content.category
          tags << ' ' << cat.name
        end
        {
          a: [ content.title, content.meta_title ],
          b: tags,
          c: [ content.teaser, content.meta_description ],
          d: content.body.to_s
        }
      end

    end
  end
end
