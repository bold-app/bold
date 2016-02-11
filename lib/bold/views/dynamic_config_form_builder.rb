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
  module Views
    class DynamicConfigFormBuilder < SimpleForm::FormBuilder

      def config_input(name, simple_form_options = {})
        simple_form_options[:input_html] ||= {}
        simple_form_options[:input_html].reverse_merge! value: object.config[name.to_s]
        simple_form_options[:as] ||= :string
        simple_form_options[:label] ||= I18n.t("simple_form.labels.theme_config.#{name}")
        input "config[#{name}]", simple_form_options
      end

    end
  end
end