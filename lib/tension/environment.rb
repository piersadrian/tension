module Tension
  class Environment

    class << self

      # TODO: finish asset type iteration in different container dirs

      ASSET_TYPES = { "javascripts" => "js", "stylesheets" => "css" }.freeze

      # This method collects all asset paths for the asset pipeline to
      # precompile. It determines which additional assets to include in the
      # pipeline's precompilation process. You can set your module scopes:
      #
      #   Rails.application.config.tension_modules = %W( blog account )
      #
      # Environment will then search for all javascripts and stylesheets
      # within those scopes. The search paths become:
      #
      #   app/assets/{javascripts,stylesheets}/*.{js,css}
      #   app/assets/{javascripts,stylesheets}/{blog,account}/**/*.{js,css}
      # 
      # Any assets at these paths will be compiled if they exist.
      # 
      def asset_paths
        if @asset_paths.nil?
          @asset_paths = Array.new

          asset_index = if Rails.env.production?
            Rails.application.assets.index
          else
            Rails.application.assets
          end

          search_paths.each_pair do |path, actions|
            actions.each do |action|

              ASSET_TYPES.each do |extension|
                asset_path = "#{ [ path, action ].join("/") }.#{ extension }"
                puts asset_path.inspect
                @asset_paths.push( asset_path ) if asset_index.find_asset( asset_path )
              end

            end
          end

          @asset_paths.compact!
        end

        @asset_paths
      end

      def controller_paths
        search_paths.keys
      end


      private

      # A hash of controller paths mapped to action names. These controller/action
      # pairs correspond to configured routes for which assets may be required.
      # 
      #   e.g. { "blog" => [index, show], "admin/blog" => [index, show, edit] }
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
        @configured_route_defaults = if @configured_route_defaults.nil?
          get_routes = Rails.application.routes.routes.find_all do |route|
            route.verb.match("GET")
          end

          get_routes.map do |route|
            route.defaults unless route.defaults.empty?
          end.compact
        end

        @configured_route_defaults
      end

      # Loads the file paths within a given subdirectory of "app/assets/".
      # def glob_within_asset_path type, *path_parts
      #   # Only recursively find children if a particular subdirectory of an
      #   # asset `type` is given. That way we can specify WHICH subdirectories
      #   # of a `type` have assets that matter.
      #   path_parts << "**" if path_parts.present?

      #   # Build the filename pattern used to search for files.
      #   root_path = File.join(Rails.root, "app", "assets", type)
      #   pattern   = File.expand_path( File.join(*path_parts, "*.*"), root_path )

      #   # Glob for any valid files under the filename pattern.
      #   paths = Dir.glob( pattern ).map do |file_path|
      #     # Remove extra, pre-compilation file extensions and any part of the
      #     # filepath at or above the asset `type`.
      #     file_path.gsub( file_path.match(/(\.css|\.js)(.*)/)[2], '' )
      #              .gsub( root_path + "/", '' ) rescue nil
      #   end

      #   paths.compact
      # end

    end

  end
end
