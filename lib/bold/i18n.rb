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
  module I18n
    module_function

    # this method works like `::I18n.t`, but tries to look up the given `key`
    # in the `themes.<theme_name>`namespace first. Used to allow themes to
    # provide their own translations.
    def t(key, options = {})
      if site = Site.current
        theme_key = "themes.#{site.theme_name}.#{key}"
        begin
          return ::I18n.t(theme_key, options.merge(:raise => true))
        rescue ::I18n::MissingTranslationData
        end
      end
      ::I18n.t key, options
    end

    # Controller mixin for locale setting.
    module AutoLocale
      def available_locales
        ::I18n.available_locales
      end

      def auto_locale
        http_accept_language.compatible_language_from available_locales
      end

      def set_locale(&block)
        old_locale = ::I18n.locale
        if user_signed_in? and locale = current_user.backend_locale and available_locales.include?(locale.to_sym)
          ::I18n.locale = locale
        elsif locale = auto_locale
          ::I18n.locale = locale
        end
        block.call
      ensure
        ::I18n.locale = old_locale
      end
    end

  end
end