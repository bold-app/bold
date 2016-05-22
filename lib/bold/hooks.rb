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

  # This is heavily derived from Redmine's Hook module
  module Hooks
    @@listener_classes = []
    @@listeners = nil
    @@hook_listeners = {}

    class << self
      # Adds a listener class.
      # Automatically called when a class inherits from Bold::Hooks::Listener.
      def add_listener(klass)
        raise "Hooks must include Singleton module." unless klass.included_modules.include?(Singleton)
        @@listener_classes << klass
        clear_listeners_instances
      end

      def remove_listener(klass)
        @@listener_classes.delete klass
      end

      # Returns all the listerners instances.
      def listeners
        @@listeners ||= @@listener_classes.collect {|listener| listener.instance}
      end

      # Returns the listeners instances for the given hook.
      def hook_listeners(hook)
        @@hook_listeners[hook] ||= listeners.select {|listener| listener.respond_to?(hook)}
      end

      # Clears all the listeners.
      def clear_listeners
        @@listener_classes = []
        clear_listeners_instances
      end

      # Clears all the listeners instances.
      def clear_listeners_instances
        @@listeners = nil
        @@hook_listeners = {}
      end

      # Calls a hook.
      # Returns the listeners response.
      def call_hook(hook, context={})
        [].tap do |response|
          hls = hook_listeners(hook)
          if hls.any?
            hls.each {|listener| response << listener.send(hook, context)}
          end
        end
      end
    end

    # Base class for hook listeners.
    class Listener
      include Singleton
      #include Redmine::I18n

      # Registers the listener
      def self.inherited(child)
        Bold::Hooks.add_listener(child)
        super
      end

    end

    # Listener class used for view hooks.
    # Listeners that inherit this class will include various helpers by default.
    #
    #   class MyHook < Bold::Hooks::ViewListener
    #     def view_issues_show_details_bottom
    #       render partial: "show_more_data"
    #     end
    #   end
    #
    class ViewListener < Listener
      include Draper::ViewHelpers
      include Draper::LazyHelpers

      # Default to creating links using only the path.  Subclasses can
      # change this default as needed
      def self.default_url_options
        { only_path: true }
      end

      # Helper method to directly render a partial using the context:
      #
      #   class MyHook < Bold::Hooks::ViewListener
      #     render_on :view_issues_show_details_bottom, :partial => "show_more_data"
      #   end
      #
      # the partial will receive any context from the call_hook call as
      # :locals hash. Hooks that are called from Builder templates will receive
      # the builder object as :builder in their locals.
      #
      def self.render_on(hook, options={})
        condition = options.delete :if
        define_method hook do |context|
          return if condition and !condition.call(context)
          render({locals: context}.update(options))
        end
      end
    end


    # Helper module included in ActionController so that hooks can be called
    # like this:
    #
    #   call_hook(:some_hook)
    #   call_hook(:another_hook, :foo => 'bar')
    #
    # The method returns an array containing the result of each hooked method.
    #
    # The hook method arguments are enriched by one element: hook_caller which
    # holds the object that called call_hook.
    #
    module Helper
      def call_hook(hook, context={})
        Bold::Hooks.call_hook hook, { hook_caller: self }.update(context)
      end
    end

    # Helper module included in Views so that hooks can be called like this:
    #
    #   <%= call_hook(:some_hook) %>
    #   <%= call_hook(:another_hook, :foo => 'bar') %>
    #
    # Output of view hooks will be concatenated into a string which is then
    # html_safe'd. That means hook code has to ensure everything is properly
    # escaped and safe.
    #
    # View hooks get the full environment as if they were directly called in
    # the view.
    #
    module ViewHelper
      def call_hook(hook, context={})
        Bold::Hooks.call_hook(hook, context).join(' ').html_safe
      end
    end
  end

end
