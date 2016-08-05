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
module Taggable

  def self.prepended(clazz)
    clazz.class_eval do

      has_many :taggings, as: :taggable, dependent: :destroy
      has_many :tags, through: :taggings

      scope :tagged_with, ->(tag){
        if tag.is_a? Tag
          joins(:tags).where('tags.id = ?'.freeze, tag.id)
        else
          joins(:tags).where('lower(tags.name) = ?'.freeze, tag.to_s.unicode_downcase)
        end
      }

      attr_writer :tag_list
    end
  end

  def tag_list
    @tag_list ||= Tag.join_tag_names tags.map(&:quoted_name)
  end

  def reload
    super
    @tag_list = nil
  end

end
