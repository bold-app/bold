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
class Tagging < ActiveRecord::Base
  belongs_to :tag, counter_cache: :taggings_count
  belongs_to :taggable, polymorphic: true

  validates_presence_of :tag
  validates_uniqueness_of :tag_id, scope: [:taggable_type, :taggable_id]

  after_destroy :remove_unused_tags

  private

  def remove_unused_tags
    tag.reload
    tag.destroy if tag.taggings_count.zero?
  end
end