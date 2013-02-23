module Tension
  class Application

    class << self

      # This method collects all asset paths for the asset pipeline to
      # precompile. It's called from `config/application.rb` when determining
      # which additional assets to include in the pipeline's precompilation
      # process. Tension will assume that any subdirectories in your assets
      # directory are module scopes. You can also explicitly set module scopes:
      #
      #   Rails.application.config.tension_modules = %W( blog account )
      #
      # Tension::Application will then search for all javascripts and stylesheets
      # one filesystem level deep in those scopes. The search paths become:
      #
      #   app/assets/{javascripts,stylesheets}/*.{js,css}
      #   app/assets/{javascripts,stylesheets}/{blog,account}/**/*.{js,css}
      # 
      # Any assets in these paths will be added to the pipeline and compiled.

      def collect_assets
        assets = %W(stylesheets javascripts).map do |type|
          glob_within_asset_path( type ) + module_scopes.map do |scope|
            glob_within_asset_path( type, scope )
          end
        end

        assets.flatten
      end


      private

      def module_scopes
        # find dirs in app/assets
      end

      # Loads the file paths within a given subdirectory of "app/assets/".
      def glob_within_asset_path type, *path_parts
        # Only recursively find children if a particular subdirectory of an
        # asset `type` is given. That way we can specify WHICH subdirectories
        # of a `type` have assets that matter.
        path_parts << "**" if path_parts.present?

        root_path = File.join(Rails.root, "app", "assets", type)
        pattern   = File.expand_path( File.join(*path_parts, "*.*"), root_path )

        paths = Dir.glob( pattern ).map do |file_path|
          # Remove extra, pre-compilation file extensions and any part of the
          # filepath at or above the asset `type`.
          file_path.gsub( file_path.match(/(\.css|\.js)(.*)/)[2], '' )
                   .gsub( root_path + "/", '' ) rescue nil
        end

        paths.compact
      end

    end

  end
end
