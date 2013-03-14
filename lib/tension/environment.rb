module Tension
  class Environment

    class << self

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
      # Any assets at these paths will be added to the pipeline and compiled.

      def collect_assets
        assets = Array.new

        %W(stylesheets javascripts).map do |type|
          assets += glob_within_asset_path( type )
          assets += module_scopes.map do |scope_path|
            glob_within_asset_path( type, scope_path )
          end
        end

        assets.flatten
      end


      private

      def module_scopes
        Rails.application.config.try(:tension_modules)
      end

      # Loads the file paths within a given subdirectory of "app/assets/".
      def glob_within_asset_path type, *path_parts
        # Only recursively find children if a particular subdirectory of an
        # asset `type` is given. That way we can specify WHICH subdirectories
        # of a `type` have assets that matter.
        path_parts << "**" if path_parts.present?

        # Build the filename pattern used to search for files.
        root_path = File.join(Rails.root, "app", "assets", type)
        pattern   = File.expand_path( File.join(*path_parts, "*.*"), root_path )

        # Glob for any valid files under the filename pattern.
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
