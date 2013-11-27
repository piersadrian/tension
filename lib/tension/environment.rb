module Tension

  # This class describes routes and controller contexts, and through those contexts
  # the assets to be included in templates.
  #
  class Environment

    attr_reader :assets, :controllers

    # Loads a Context for the specified controller path.
    #
    def find_context(key)
      fetch( Tension::Utils.controller_path(key) )
    end

    # Returns a Sprockets::Asset for the given logical path. Will load assets
    # cached from a manifest if available, but in development falls back to
    # the Sprockets::Index as assets may be under development.
    #
    def find_asset(logical_path)
      if assets_cached?
        assets[logical_path]
      else
        Rails.application.assets.find_asset(logical_path)
      end
    end

    # A Hash mapping controller paths to Contexts.
    #
    def contexts
      @contexts ||= Hash.new
    end

    def controllers
      @controllers ||= Hash.new
    end


    private

    def fetch(path)
      (contexts[path] || store(path)) if path.present?
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
      @configured_get_defaults ||= Rails.application.routes.routes.map do |route|
        route.defaults if route.verb.match("GET") && !route.defaults.empty?
      end.compact
    end

  end

  class Asset
    def initialize(attributes)
      @attributes = attributes
    end

    def logical_path
      @attributes[:logical_path]
    end
  end
end
