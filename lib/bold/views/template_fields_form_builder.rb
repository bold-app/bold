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
    class TemplateFieldsFormBuilder < SimpleForm::FormBuilder

      # renders a simple_form field for the named template field.
      # see the simple_form docs for available options
      def field_input(name, simple_form_options = {})
        simple_form_options[:label] ||= name.to_s.humanize
        simple_form_options[:input_html] ||= {}
        simple_form_options[:input_html].reverse_merge!(
          class: 'input-sm',
          value: object.template_field_value(name)
        )
        simple_form_options[:as] ||= :string
        input name.to_s, simple_form_options
      end

      def checkbox_input(name, simple_form_options = {})
        default = simple_form_options.delete :default
        if true == default
          default = 1
        elsif false == default
          default = 0
        end
        field_input name,
          input_html: {
            class: 'input-sm',
            checked: 1 == (object.template_field_value(name) || default).to_i
          },
          as: :boolean,
          wrapper: :vertical_boolean
      end
      alias checkbox checkbox_input

      # Renders an image picker form control.
      # The selected image's id will be stored as th field value.
      def image_picker_input(name, options = {})
        id = "content_template_field_values_#{name}"
        value = object.template_field_value(name)
        img = object.site.assets.find_by_id(value) if value.present?
        template.content_tag :div, class: 'form-group' do
          out = ''.html_safe
          out << template.label_tag(name, options[:label] || name.to_s.humanize)
          out << template.content_tag(:p, class: 'small') do
            template.link_with_icon(:picture, I18n.t('bold.asset_links.form_builder.click_to_select'), template.new_bold_site_asset_link_path(Bold.current_site, rel: id), remote: true) + '&nbsp;'.html_safe +
            template.link_to(template.icon(:remove) + ' ' +  I18n.t('bold.asset_links.form_builder.remove_image'), '#', rel: id, class: 'clear', style:('display: none;' if img.nil?))
          end
          out << hidden_field(name.to_s, value: value)
          out << template.content_tag(:p, id: "#{id}_preview", class: 'thumb') do
            if img
              template.asset_tag(img, :bold_thumb)
            end
          end
          out
        end
      end

    end
  end
end
