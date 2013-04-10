module Tension

  # Tension::Environment exposes `asset_paths`, which describes the assets that
  # can be automatically included in templates.
  #
  # It's used automatically on application load (see Tension::Railtie) to populate
  # the asset pipeline's list of assets to precompile, and caches the result in-
  # process for use by Tension::Tagger when templates are rendered.
  #
  class Environment

    class << self

      GLOBAL_KEY    = "::globals".freeze
      COMMON_SUFFIX = "_common".freeze
      ASSET_TYPES   = [{ container: "javascripts", extension: "js" },
                       { container: "stylesheets", extension: "css" }].freeze

      # This method collects all asset paths for the asset pipeline to
      # precompile. It determines which additional assets to include in the
      # pipeline's precompilation process, so they can be automatically added
      # to templates later (see Tension::Tagger).
      #
      # If an application's routes include `resources :people`, `asset_map`
      # will attempt to locate the following assets:
      #
      #   + people_common.{js,css}
      #   + people/index.{js,css}
      #   + people/show.{js,css}
      #   + people/new.{js,css}
      #   + people/edit.{js,css}
      #
      # Note that Tension ignores Sprockets' interpretation of `index.{js,css}`
      # as a shared file, and therefore requires the `_common` suffix for
      # controller-wide assets.
      #
      # Returns: an Hash of controller paths, each containing that controller's
      # routed GET actions mapped to each action's best matching asset. E.g.
      #
      #   { "people" => {
      #       "index" => {
      #         "js" => "javascripts/people/index.js",
      #         "css" => "javascripts/people_common.css"
      #       },
      #       "show" => {
      #         "js" => "javascripts/application.js",
      #         "css" => "javascripts/people_common.css"
      #       }
      #   }
      #
      def asset_map
        @asset_map = nil if Rails.env.development?

        @asset_map ||= begin
          map      = Hash.new
          globals  = Hash.new

          ASSET_TYPES.each do |type|
            # Find and store the global asset for this type.
            global_asset = valid_asset( "application.#{ type[:extension] }" )
            globals.store( type[:extension], global_asset )
          end

          # TODO: add support for looking up the tree...
          search_paths.each_pair do |controller_path, actions|
            map.store( controller_path, Hash.new )

            ASSET_TYPES.each do |type|
              # Attempt to locate a common asset for this controller.
              common_path = "#{ controller_path }#{ COMMON_SUFFIX }.#{ type[:extension] }"
              common_asset = valid_asset( common_path ) || globals.fetch( type[:extension] )

              actions.each do |action|
                unless map[ controller_path ].has_key?( action )
                  map.fetch( controller_path ).store( action, Hash.new )
                end

                action_asset = valid_asset( "#{ [ controller_path, action ].join("/") }.#{ type[:extension] }" )
                map.fetch( controller_path )
                   .fetch( action )
                   .store( type[:extension], action_asset || common_asset )
              end
            end

          end

          map
        end
      end

      # All unique, existing asset paths.
      def asset_paths
        @asset_paths ||= Set.new.merge( extract_paths(asset_map) ).to_a
      end


      private

      # Recursively extracts all paths from the `asset_map`.
      def extract_paths hash
        paths = Array.new

        hash.each_pair do |key, value|
          if value.is_a?(Hash)
            paths.concat( extract_paths(value) )
          else
            paths << value.pathname.to_s
          end
        end

        paths
      end

      # A hash of controller paths mapped to action names. These controller/action
      # pairs correspond to configured routes for which assets may be required.
      #
      #   e.g. { "blog"       => [ "index", "show" ],
      #          "admin/blog" => [ "index", "show", "edit" ] }
      #
      def search_paths
        @search_paths ||= configured_route_defaults.reduce( Hash.new ) do |accum, route_default|
          accum[ route_default[:controller] ] ||= Array.new
          accum[ route_default[:controller] ].push( route_default[:action] )

          accum
        end
      end

      # Routing defaults (including controller path and action name) for all
      # configured GET routes.
      #
      def configured_route_defaults
        @configured_route_defaults ||= begin
          get_routes = Rails.application.routes.routes.find_all do |route|
            route.verb.match("GET")
          end

          @configured_route_defaults = get_routes.map do |route|
            route.defaults unless route.defaults.empty?
          end

          @configured_route_defaults.compact!
        end
      end

      # Returns: a real BundledAsset present in the Sprockets index, or nil
      # if no asset was found.
      #
      def valid_asset asset_path
        Rails.application.assets.find_asset( asset_path )
      end
    end

  end
end
