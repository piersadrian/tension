module Tension

  # Tension::Environment exposes `assets`, which describes the assets that
  # can be automatically included in templates.
  #
  # It's used automatically on application load (see Tension::Railtie) to populate
  # the asset pipeline's list of assets to precompile, and caches the result in-
  # process for use by Tension::Tagger when templates are rendered.
  #
  class Environment

    class << self

      def [](key, action = nil)
        fetch( AssetGroup.path_for(key, action) )
      end
      alias_method :find, :[]

      def eager_load!
        configured_get_defaults.each do |default|
          find( default[:controller], default[:action] )
        end
      end

      def assets
        @assets ||= Hash.new
      end

      private

      def fetch(path)
        assets[path] || store(path)
      end

      def store(path)
        assets[path] = AssetGroup.new( path )
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
