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
  # Base class for the management of Bold extensions, plugins and themes
  #
  # Extensions are active as soon as they are added to your Gemfile. See
  # Plugin and Theme for information about how to get more fine grained
  # control.
  #
  # In parts inspired by Redmine's (redmine.org) plugin system.
  class Extension

    attr_reader :id
    attr_accessor :gem_dir

    def <=>(other)
      id <=> other.id
    end

    # Returns +true+ if the extension can be configured.
    def configurable?
      settings && settings.is_a?(Hash)
    end

    def settings_partial
      File.join template_dir, settings[:partial] if configurable?
    end

    def default_settings
      if settings && settings.key?(:defaults)
        settings[:defaults]
      else
        {}
      end
    end

    # installs a view hook
    # template is a partial name relative to template_dir
    def render_on(hook, template, options = {})
      (@hooks ||= []) << [
        hook.to_sym,
        { partial: template_path(template) }.merge(options),
      ]
    end

    # declare js and css files referenced by your extension so they are added
    # to the asset pipeline.
    def assets(*names)
      Rails.application.config.assets.precompile += names.flatten
    end

    # define your routes when registering the extension so Bold can install
    # them *before* any catch all routes.
    def routes(&block)
      if block_given?
        @routes = block
      else
        @routes
      end
    end

    def register_hooks!
      hooks = @hooks
      if hooks.present?
        @view_listener = Class.new(Bold::Hooks::ViewListener) do
          hooks.each do |hook, options|
            render_on hook, options
          end
        end
      end
    end

    def deregister_hooks!
      if @view_listener
        Bold::Hooks.remove_listener @view_listener
        @view_listener = nil
      end
    end

    def fetch_gem_metadata!
      if spec = find_gemspec
        version spec.version.to_s if version.blank?
        url spec.homepage if url.blank?
        description spec.description if description.blank?
        if author.blank? && author_url.blank?
          author spec.authors
          author_url spec.email.map{|m| "mailto:#{m}"}
        end
      end
    end

    def find_gemspec
      specs = Bundler.environment.specs.to_hash
      if name = specs.keys.detect{|k| k =~ /\Abold-#{id}\z/}
        return specs[name].last
      end
    end

    def template_path(template)
      File.join template_dir, template.to_s
    end

    def valid?
      true
    end

    # True if there is at least one file matching the given path (which may
    # contain glob patterns) in the gem declaring this extension.
    def has_file?(path)
      if p = Dir[File.join(gem_dir, path)].first
        File.readable? p
      else
        false
      end
    end


    class << self
      private :new

      def register_lock
        @lock ||= Mutex.new
      end

      def register(id, &block)
        register_lock.synchronize do
          id = id.to_sym
          new(id).tap do |ext|
            ext.instance_eval(&block)
            ext.gem_dir = begin
              # creepy but that's what Rails::Engine does as well...
              call_stack = if Kernel.respond_to?(:caller_locations)
                caller_locations.map { |l| l.absolute_path || l.path }
              else
                # Remove the line number from backtraces making sure we don't leave anything behind
                caller.map { |p| p.sub(/:\d+.*/, '') }
              end
              File.expand_path File.join(File.dirname(call_stack.detect {|p| p =~ /bold-(theme-)?#{ext.id}/ }), '..')
            rescue
              Rails.root
            end


            ext.name id.to_s.humanize if ext.name.blank?
            if ext.configurable? && ext.settings[:partial].blank?
              ext.settings[:partial] = 'settings'
            end
            ext.fetch_gem_metadata!
            if ext.valid?
              if old = all[ext.id]
                old.deregister_hooks!
              end
              ext.register_hooks!
              all[ext.id] = ext
            else
              Rails.logger.warn "ignoring invalid extension #{id}"
            end
          end
        end
      end

      def define_field(*names)
        class_eval do
          names.each do |name|
            define_method(name) do |*args|
              case args.size
              when 0
                instance_variable_get "@#{name}"
              when 1
                instance_variable_set "@#{name}", args.shift
              else
                instance_variable_set "@#{name}", args
              end
            end
          end
        end
      end

      def all
        @all ||= {}
      end

      def [](name)
        all[name.to_sym]
      end

      def install_routes!(router)
        all.values.each do |extension|
          if callable = extension.routes
            constraint = Bold::Routes::ExtensionConstraint.new(extension)
            router.instance_eval do
              constraints constraint do
                instance_eval(&callable)
              end
            end
          end
        end
      end
    end

    define_field :name, :description, :author, :author_url, :url, :settings, :version

    private

    def initialize(id)
      @id = id.to_sym
    end

    # templates go to app/views/{extensions,plugins,themes}/<id>/
    def template_dir
      @template_dir ||=
        File.join self.class.name.split('::').last.pluralize.underscore, id.to_s
    end

  end
end
