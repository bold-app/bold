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
class Tag < ActiveRecord::Base
  include SiteModel
  prepend HasPermalink
  prepend HasSlug

  GLUE = ', '.freeze

  # patterns for tag string parsing: double quotes, single quotes, no quotes
  PATTERNS = [
    /(\A|,)\s*"(?<tag>.*?)"\s*(?=,\s*|\z)/,
    /(\A|,)\s*'(?<tag>.*?)'\s*(?=,\s*|\z)/,
    /(\A|,)\s*(?<tag>.*?)\s*(?=,\s*|\z)/
  ]


  has_many :taggings # cascades on delete
  has_many :taggables, through: :taggings

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :site_id
  validates_length_of :name, maximum: 255

  scope :most_used, ->(limit = 20) { order('taggings_count desc').limit(limit) }
  scope :least_used, ->(limit = 20) { order('taggings_count asc').limit(limit) }
  scope :named, ->(name) { where slug: name.to_url }

  def name=(new_name)
    self.slug = new_name if slug.blank?
    super
  end

  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end

  def to_s
    name
  end

  def quoted_name
    if name[',']
      %{"#{name}"}
    else
      name
    end
  end

  def self.join_tag_names(tag_names)
    tag_names.join GLUE
  end

  # parse a tag string
  #
  # Example:
  #   tag_list = parse_tags "One , Two,  Three"
  #   tag_list # ["One", "Two", "Three"]
  def self.parse_tags(string)
    string = if string.respond_to?(:join)
      join_tag_names string
    else
      string.to_s
    end.strip

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
