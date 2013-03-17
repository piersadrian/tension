module Tension

  # Tension::Environment exposes `::asset_paths`, which describes the assets that
  # can be automatically included in templates.
  # 
  # It's used automatically on application load (see Tension::Railtie) to populate
  # the asset pipeline's list of assets to precompile, and caches the result in-
  # process for use by Tension::Tagger when templates are rendered.
  #
  class Environment

    class << self

      ASSET_TYPES = [{ container: "javascripts", extension: "js" },
                     { container: "stylesheets", extension: "css" }].freeze

      # This method collects all asset paths for the asset pipeline to
      # precompile. It determines which additional assets to include in the
      # pipeline's precompilation process, so they can be automatically added
      # to templates later (see Tension::Tagger).
      # 
      # If an application's routes include `resources :people`, `::asset_paths`
      # will attempt to locate the following assets:
      # 
      #   + people_common.{js,css}
      #   + people/index.{js,css}
      #   + people/show.{js,css}
      #   + people/new.{js,css}
      #   + people/edit.{js,css}
      #
      # Returns: an Array of fully-qualified Pathnames to existing assets.
      # 
      def asset_paths
        if @asset_paths.nil?
          @asset_paths = Array.new

          search_paths.each_pair do |controller_path, actions|
            next unless local_controller?( controller_path )

            ASSET_TYPES.each do |type|
              qualified_path = "#{ [ type[:container], controller_path ].join("/") }"

              # Attempt to locate a shared asset for this controller.
              @asset_paths << valid_asset_path( "#{ qualified_path }_common.#{ type[:extension] }" )

              actions.each do |action|
                @asset_paths << valid_asset_path( "#{ [ qualified_path, action ].join("/") }.#{ type[:extension] }" )
              end
            end
          end

          @asset_paths.compact!
        end

        @asset_paths
      end


      private

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
      def configured_route_defaults
        if @configured_route_defaults.nil?
          get_routes = Rails.application.routes.routes.find_all do |route|
            route.verb.match("GET")
          end

          @configured_route_defaults = get_routes.map do |route|
            route.defaults unless route.defaults.empty?
          end

          @configured_route_defaults.compact!
        end

        @configured_route_defaults
      end

      # Returns a Pathname identifying a real asset present in the Sprockets
      # index, or nil if no asset was found.
      def valid_asset_path asset_path
        puts "looking for #{ asset_path }"
        Rails.application.assets.find_asset( asset_path ).try(:pathname)
      end

      # True if the controller targeted in the routing table is present in this
      # app's local code rather than in a gem. Gems are responsible for ensuring
      # availability of their own assets.
      def local_controller? controller_path
        File.exists?("#{ Rails.root }/app/controllers/#{ controller_path }_controller.rb")
      end

    end

  end
end
