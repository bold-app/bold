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
class Draft < ActiveRecord::Base
  belongs_to :content

  DRAFTABLES = %w(title body slug tag_list meta_title meta_description template_field_values)

  memento_changes :destroy

  def take_changes
    return unless content

    DRAFTABLES.each do |attribute|
      next unless content.respond_to? attribute
      value = content.send attribute
      drafted_changes[attribute] = case attribute
                                   when 'template_field_values'
                                     value.to_json
                                   else
                                     value.to_s
                                   end
    end
    drafted_changes_will_change!
    content.reload
  end

  def apply_changes
    return unless content

    drafted_changes.each do |attribute, value|
      value = case attribute
              when 'template_field_values'
                JSON.parse value
              else
                value
              end
      begin
        content.send "#{attribute}=", value
      rescue NoMethodError
        # guard against schema changes
      end
    end
  end

end
