module Tension

  # This class describes routes and controller contexts, and through those contexts
  # the assets to be included in templates.
  #
  class Environment
    class << self

      # Loads a Context for the specified controller path.
      #
      def find(key)
        fetch( Tension::Utils.controller_path(key) )
      end
      alias_method :[], :find

      # A Hash mapping controller paths to Contexts.
      #
      def contexts
        @contexts ||= Hash.new
      end

      # Preloads all Contexts. Useful in environments where assets and controller
      # actions don't change without an app reboot (production, staging).
      #
      def eager_load!
        configured_get_defaults.each do |default|
          find(default[:controller])
        end

        true
      end

      # Determines whether or not a given path refers to an asset that requires
      # precompilation.
      #
      def precompilation_needed?(path)
        if context = find(path)
          context.has_action?( Tension::Utils.action_name(path) )
        end
      end


      private

      def fetch(path)
        contexts[path] || store(path)
      end

      def store(path)
        contexts[path] ||= Context.new(path) if valid_route?(path)
      end

      def valid_route?(controller)
        configured_get_defaults.find do |default|
          default[:controller] == controller
        end
      end

      # Routing defaults (including controller path and action name) for all
      # configured GET routes.
      #
      def configured_get_defaults
        @configured_get_defaults ||= begin
          get_routes = Rails.application.routes.routes.find_all do |route|
            route.verb.match("GET")
          end

          @configured_get_defaults = get_routes.map do |route|
            route.defaults unless route.defaults.empty?
          end

          @configured_get_defaults.compact!
        end
      end

    end
  end
end
