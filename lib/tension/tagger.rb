module Tension
  class Tagger

    GLOBAL_ASSET_NAME = "application".freeze
    SHARED_SUFFIX     = "_common".freeze
    ASSET_SPECIFICITY_ORDER = [ :action, :controller, :module ].freeze

    # Determines which JS/CSS files should be included based on the current
    # controller, action, and which files actually exist. If the current
    # controller is "OrcaHealth::PagesController" and action is "products",
    # this method (called with `type = :js`) will attempt to include
    #
    #   + orca_health/pages/products.js
    #   + orca_health/pages_common.js
    #   + orca_health.js
    #
    # in that order. ONLY THE FIRST ASSET LOCATED WILL BE INCLUDED. Hence,
    # you should always use Sprockets directives to include dependencies.
    #
    # Any files that don't exist will not be included in the page. Pass
    # `{ except: :application }` to exclude `application.{js,css}`.

    def self.asset_paths type, controller_path, action_name, options = {}
      options[:except] = [ options[:except] ] unless options[:except].is_a? Array

      # Check if the best asset's already been loaded and stored.
      asset = known_asset_paths[ controller_path ].try(:fetch, action_name, nil).try(:fetch, type, nil)

      if asset.nil?
        path_components = controller_path.split("/")
        controller_name = path_components.pop
        module_path     = path_components.join("/")

        possible_paths = {
          module:     module_path,
          controller: [ module_path, controller_name + SHARED_SUFFIX ].join("/"),
          action:     [ module_path, controller_name, action_name ].join("/")
        }

        # Find and store the best possible asset for this controller/action combo.
        asset = most_specific_asset_path( type, possible_paths )

        known_asset_paths[ controller_path ] ||= Hash.new
        known_asset_paths[ controller_path ][ action_name ] ||= Hash.new
        known_asset_paths[ controller_path ][ action_name ][ type ] = asset
      end

      assets = if options[:except].include? :application
        [ asset ]
      else
        [ GLOBAL_ASSET_NAME, asset ]
      end

      assets.compact
    end


    private

    def self.known_asset_paths
      @known_asset_paths ||= Hash.new
    end

    def self.most_specific_asset_path filetype, paths
      ASSET_SPECIFICITY_ORDER.each do |name|
        path = paths[name]

        # Using the Sprockets `#index` helps performance in production.
        asset = if Rails.env.production?
          Rails.application.assets.index.find_asset([ path, filetype ].join("."))
        else
          Rails.application.assets.find_asset([ path, filetype ].join("."))
        end

        # This loop is relatively expensive, so return the asset path as soon
        # as possible rather than continue looping.
        break path if asset.present?
      end
    end

  end
end
