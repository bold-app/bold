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

    # Creates SQL statements to create a text search configuration for the
    # given language.
    #
    # Possible languages for a stock PostgreSQL 9.3 installation are:
    # danish dutch english finnish french german hungarian italian
    # norwegian portuguese romanian russian spanish swedish turkish
    #
    # check \dF in your psql shell for the list of your setup.
    #
    def self.sql_for_language_config(language = 'english')
      raise "invalid language: #{language}!" if language !~ /\A[a-z]+\z/i
      <<-SQL
        CREATE TEXT SEARCH CONFIGURATION bold_#{language} (COPY = '#{language}');
        ALTER TEXT SEARCH CONFIGURATION bold_#{language}
          ALTER MAPPING FOR hword, hword_part, word with unaccent, english_stem;
        ALTER TEXT SEARCH CONFIGURATION bold_#{language}
          drop mapping for float, int, uint, sfloat, version;
      SQL
    end


  end
end
