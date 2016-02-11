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

  # = Themes
  #
  # Themes are used to customize the appearance of sites. They combine any
  # number of view templates, a custom layout (optional), Javascript and
  # Stylesheets. Technically themes are Rails engines and as such may also
  # contain custom code in the form of controllers, models and custom routes.
  #
  #
  # == Templates
  #
  # Templates are normal Rails partials written using ERb or Haml (or any other
  # Rails-compatible view layer, just declare the relevant dependencies in your gemspec).
  #
  # In your Theme, declare templates template method:
  #
  #   # templates declaring body: false do not have their own content and
  #   # are exempted from fulltext search. Use this flag for post listings and
  #   # other special page types that do not have their own content.
  #   template :homepage, body: false
  #   template :homepage_with_greeting, body: false, for: :homepage, fields: %w(greeting)
  #
  #   # A template for listing posts by tag. This one has a body text, but we
  #   # still don't want to have this kind of index page found by fulltext
  #   # search:
  #   template :tag, fulltext_search: false
  #   template :page
  #   template :page_alternate, for: :page
  #   template :post
  #
  # Bold tries to guess which template to use as a default based on the
  # template name (first argument). These 'well known' template names are:
  #
  # * +homepage+ Homepage template
  # * +tag+ Template for the result of a tag search
  # * +archive+ Template for archive display (either by month or year)
  # * +post+ Post template
  # * +page+ Page template
  #
  # Template names have to be unique per theme and for each declared template
  # there needs to be a corresponding view template with a matching name:
  # +app/vies/themes/theme_name/_template_name.html.{haml,erb}+
  #
  # In order to declare more than one template for a given usage, you may specify
  # the intended use using the +for+ option as can be seen above with the
  # +homepage_with_greeting+ and +page_alternate+ templates.
  #
  # Templates that do not render their content's body (usually these are the
  # list kind templates like tag, archive or homepage) should declare so using
  # +body: false+.
  #
  # === Template fields
  #
  # Use the +fields+ option to declare any fields that instances of this template
  # should have. You also have to provide a partial named +_templatename+ in
  # a +fields+ subdirectory of your theme's template directory.
  # in this case, which renders the form html for these fields. This partial
  # will get a SimpleForm Formbuilder instance as local variable +f+ and will
  # be rendered in the sidebar of the editing view.
  #
  #
  # == View Hooks
  #
  # == Layout
  #
  # By default, all templates are rendered with Bold's +content+ layout, which
  # does nothing more than render HTML boilerplate, call any declared hooks in
  # the right places and render the template. When using this layout, common
  # html code like header and footer is usually placed in view hooks to avoid
  # duplication.
  #
  # You can however also give your theme a custom layout (derive it from the
  # default layout to not miss any of the Bold methods inserting meta data and
  # hook content). When named +layout.html.erb+ or +layout.html.haml+ this
  # layout will be discovered and used automatically, if you prefer a different
  # name declare the layout explicitly:
  #
  #     # expects the file at
  #     # app/views/themes/<theme_id>/my_custom_layout.html.{haml,erb}
  #     layout :my_custom_layout
  #
  # == Theme Assets
  #
  # == I18n
  #
  # == Routes
  #
  class Theme < Extension

    define_field :layout, :locales

    def template(name, *args)
      return nil if name.blank?
      options = args.extract_options!
      path = args.shift || name.to_s
      name = name.to_sym
      templates[name] ||= Template.new(name, template_path(path), options.merge(theme_name: self.id))
    end

    def layout_path
      template_path(layout) if layout
    end


    # declare js and css files referenced by your theme so they are added
    # to the asset pipeline.
    def assets(*names)
      Rails.application.config.assets.precompile += names.flatten
    end

    def templates
      @templates ||= {}
    end

    def template?(name)
      templates.key?(name.to_sym)
    end

    def homepage_template
      find_template *Template::USAGE_KEYS[:homepage]
    end

    # find_template :homepage, :page
    #
    # Will find the first template that is named homepage or is declared to be
    # +for: :homepage+, if none is found, the same is repeated for :page
    #
    # The given name(s) are expanded using Template::USAGE_KEYS, so a search
    # for :tag will fall back to :post_listing if necessary
    def find_template(*names)
      names = names.map{|n| Template.expand_usage n}.flatten.compact
      names.map(&:to_sym).each do |name|
        if tpl = templates[name] || templates.values.detect{|t| t.usage == name}
          return tpl
        end
      end
      nil
    end

    # all templates that have a body
    def content_templates
      templates.values.select{|tpl| tpl.body?}
    end

    # all templates that do not have a body themselves, i.e. tag / category /
    # author pages
    def non_content_templates
      templates.values.select{|tpl| !tpl.body?}
    end

    # installs a view hook which will only be rendered if this is the active
    # theme of the current site.
    def render_on(hook, template)
      super hook, template, if: ->(context){ Site.current.theme_name == id.to_s }
    end

    # Declares an image version. To avoid collisions it is a good idea to
    # prefix image version names with the theme name.
    # TODO do the name prefixing implicitly
    def image_version(name, options = {})
      image_versions[name.to_sym] = ImageVersion.new options.merge(name: name)
    end

    def image_versions
      @image_versions ||= {}
    end

    def find_gemspec
      specs = Bundler.environment.specs.to_hash
      if name = specs.keys.detect{|k| k =~ /\Abold-theme-#{id}\z/}
        return specs[name].last
      end
    end

    def valid?
      super && homepage_template.present? && image_versions.values.detect{|v| !v.valid?}.nil?
    end

    class << self

      def all_themes
        all.values.
          reject{ |t| !Rails.env.test? && t.id == :none }.
          sort  { |a, b| a.name.downcase <=> b.name.downcase }
      end

      def [](name)
        super or raise ThemeNotFound.new("theme '#{name}' does not exist")
      end

      def register(*args)
        super.tap do |theme|
          # use the default layout if present
          if theme.layout.blank? && theme.has_file?("app/views/themes/#{theme.id}/layout.html.{erb,haml}")
            theme.layout 'layout'
          end
          if theme.locales.blank?
            theme.locales [:en]
          end
        end
      end

    end

  end
end