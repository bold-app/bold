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

  GLUE = ', '.freeze

  # patterns for tag string parsing: double quotes, single quotes, no quotes
  PATTERNS = [
    /(\A|,)\s*"(?<tag>.*?)"\s*(?=,\s*|\z)/,
    /(\A|,)\s*'(?<tag>.*?)'\s*(?=,\s*|\z)/,
    /(\A|,)\s*(?<tag>.*?)\s*(?=,\s*|\z)/
  ]

  def self.prepended(clazz)
    clazz.class_eval do
      has_many :taggings, as: :taggable, dependent: :destroy
      has_many :tags, through: :taggings

      scope :tagged_with, ->(name){
        if Tag === name
          joins(:tags).where('tags.id = ?'.freeze, name.id)
        else
          joins(:tags).where('lower(tags.name) = ?'.freeze, name.to_s.unicode_downcase)
        end
      }
    end
  end

  def tag_list
    # we go through taggings instead of tags to get the tags potentially
    # updated by tag_list=
    taggings.map(&:tag).compact.map(&:quoted_name).join GLUE
  end

  def tag_list=(string)
    site = self.site || Site.current
    old_ids = taggings.map(&:id).sort
    self.taggings = parse_tags(string).map do |name|
      tag = site.tags.named(name).first || site.tags.build(name: name)

      (tag.persisted? and self.taggings.find_by_tag_id(tag.id)) or self.taggings.build(tag: tag)
    end
    if old_ids != taggings.map{|t|t.id.to_s}.sort
      @tags_changed = true
    end
  end

  def tags_changed?
    !!@tags_changed
  end

  def changed?
    super || tags_changed?
  end

  # parse a tag string
  #
  # Example:
  #   tag_list = parse_tags "One , Two,  Three"
  #   tag_list # ["One", "Two", "Three"]
  def parse_tags(string)
    if string.respond_to?(:join)
      string = string.join(GLUE)
    else
      string = string.to_s.dup
    end
    string.strip!
    [].tap do |tag_list|
      PATTERNS.each do |pat|
        string.gsub!(pat) do |match|
          tag_list << $~['tag']
          ''
        end
      end
      tag_list.reject!(&:blank?)
      tag_list.compact!
    end
  end

end
