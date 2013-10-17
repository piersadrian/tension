module Tension
  module Utils
    class << self

      SHARED_SUFFIX   = "_common".freeze
      SHARED_REGEX    = /#{SHARED_SUFFIX}\..*\z/.freeze
      EXTENSION_REGEX = /(#{SHARED_SUFFIX})?\..*\z/.freeze

      # Matches strings like "blog/comments".
      CONTROLLER_REGEX = /([\w\/]+[^\.])/.freeze

      # Attempts to build a valid controller path from the given path String.
      #   ARGS: path: a String path like "admin/blog_common.css"
      #
      def controller_path(path)
        if asset_path?(path)
          return controller_for_asset_path(path)

        elsif matches = path.split("#").first.match(CONTROLLER_REGEX)
          return matches[0]
        end
      end

      # Attempts to find an action name for a given asset path.
      #
      def action_name(path)
        strip_file_extension( path.split("/").last ) if asset_path?(path)
      end

      # Determines whether an asset path is shared amongst all actions
      # for its controller.
      #
      def shared_asset?(path)
        !!path.match(SHARED_SUFFIX)
      end

      # Attempts to load an Asset from the Sprockets index. Uses the given
      # Hash argument to build an asset path.
      #   ARGS: options: a Hash containing e.g.
      #     controller: "blog/comments"
      #     action: "index"
      #     type: Tension::CSS
      #
      def find_asset(options)
        Tension.environment.assets[ logical_asset_path(options) ]
      end

      # Returns the application-wide Sprockets Asset for the given type.
      #   ARGS: type: Tension::JS or Tension::CSS
      #
      def global_asset(type)
        Tension.environment.assets[ "application.#{type}" ]
      end

      private

      # Builds a String path for an asset based on the given hash params.
      #   ARGS: options: a Hash containing e.g.
      #     controller: "blog/comments"
      #     action: "index"
      #     type: Tension::CSS
      #
      def logical_asset_path(options)
        if options[:action].nil?
          "#{options[:controller]}#{SHARED_SUFFIX}.#{options[:type]}"
        else
          "#{options[:controller]}/#{options[:action]}.#{options[:type]}"
        end
      end

      # Takes an asset path like "comments/base/index.js" and determines
      # the controller ("comments/base") that should serve that asset.
      #   ARGS: path: a String path like "admin/blog_common.css"
      #
      def controller_for_asset_path(path)
        parts = path.split("/")

        if shared_asset?(parts.last)
          parts.push(strip_file_extension( parts.pop ))
        else
          parts.pop
        end

        return parts.any? ? parts.join("/") : nil
      end

      def strip_file_extension(path)
        path.gsub(EXTENSION_REGEX, "")
      end

      # Returns whether or not the given path represents an asset file
      # for which Tension is useful: JavaScript or CSS.
      #   ARGS: path: a String path like "admin/blog_common.css"
      #
      def asset_path?(path)
        path.match(/\.(#{ Tension::CSS }|#{ Tension::JS })\z/)
      end

    end
  end
end
