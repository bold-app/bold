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
  class Template

    attr_accessor :file, :key, :usage
    attr_reader :options

    def has_body?
      false != @options[:body]
    end
    alias body? has_body?

    def initialize(key, filename, options = {})
      @key = key
      @file = filename
      @options = options
      @theme_name = options.delete :theme_name

      @options[:fields] ||= []
    end

    # mapping of 'special' page types to potential template types for these use
    # cases
    USAGE_KEYS = {
      homepage:  %i(homepage page default),
      not_found: %i(not_found page default),
      error:     %i(error page default),
      tag:       %i(tag post_listing),
      category:  %i(category post_listing),
      author:    %i(author post_listing),
      archive:   %i(archive post_listing),
      search:    %i(search post_listing),
    }

    def self.expand_usage(name)
      USAGE_KEYS[name] || [name]
    end

    # the type of this template determining it's possible uses. This should be
    # one of :default, :page, :post, :homepage, :post_listing, :not_found,
    # :tag, :author, :archive, :category
    def usage
      @options[:for] || key
    end

    def name
      key.to_s
    end

    def pretty_name
      @name ||= begin
        ::Bold::I18n.t "templates.#{key}", raise: true
      rescue ::I18n::MissingTranslationData
        key.to_s.humanize
      end
    end

    def fields?
      fields.present?
    end

    def field?(name)
      name = name.to_s
      field_names.any?{|n| n == name}
    end

    # contents using a template will be indexed for fulltext search if this
    # returns true.
    def fulltext_searchable?
      @options[:fulltext_search].nil? ? has_body? : @options[:fulltext_search]
    end

    def fields
      options[:fields]
    end

    def field_names
      fields.map(&:to_s)
    end

  end
end