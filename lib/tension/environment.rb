module Tension

  # This class describes routes and controller contexts, and through those contexts
  # the assets to be included in templates.
  #
  class Environment

    attr_reader :assets, :controllers

    def initialize(assets_path)
      if assets_cached?
        cache_assets_from_manifest!(Sprockets::Manifest.new(assets_path))
      end
    end

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

    # Determines whether or not a given path refers to an asset that requires
    # precompilation.
    #
    def precompilation_needed?(path)
      if cxt = find_context(path)
        Tension::Utils.shared_asset?(path) || cxt.has_action?( Tension::Utils.action_name(path) )
      end
    end


    private

    def fetch(path)
      contexts[path] || store(path) unless path.nil?
    end

    def store(path)
      contexts[path] ||= Context.new(path) if valid_route?(path)
    end

    def valid_route?(controller)
      configured_get_defaults.find do |default|
        default[:controller] == controller
      end
    end

    def assets_cached?
      ! Rails.env.development? && ! Rails.application.config.assets.compile
    end

    def cache_assets_from_manifest!(manifest)
      @assets = Hash.new
      manifest.files.each do |full_path, info|
        next unless full_path.match(/\.css|\.js\z/)

        info = info.merge(full_path: full_path).with_indifferent_access
        @assets[ info[:logical_path] ] = Asset.new(info)
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
