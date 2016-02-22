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
module DecoratedAssignments

  def self.prepended(clazz)
    clazz.class_eval do
      extend ClassMethods
      class_attribute :things_to_decorate, instance_accessor: false
      self.things_to_decorate = []
    end
  end

  def render(*args)
    decorate_things
    super
  end

  def decorate_things
    self.class.things_to_decorate.each do |vars, options|
      vars.each do |var|
        name = "@#{var}"
        if value = instance_variable_get(name)
          decorated_value = if decorator = options[:with]
            decorator = decorator.constantize
            if (Enumerable === value || ActiveRecord::Relation === value) && !(decorator < Draper::CollectionDecorator)
              decorator.decorate_collection value
            else
              decorator.decorate value
            end
          else
            value.decorate
          end
          instance_variable_set(name, decorated_value)
        end
      end
    end
  end
  private :decorate_things

  module ClassMethods
    def decorate_assigned(*args)
      options = args.extract_options!
      self.things_to_decorate += [[args, options]]
    end
  end

end
