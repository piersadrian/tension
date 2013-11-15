require 'active_support/concern'

module Tension

  # Helper is included in ActionView::Helpers so it can be called from
  # templates and layouts.
  module Helper
    extend ActiveSupport::Concern

    # Determines the best stylesheets to be included in a template based
    # on the current controller and action.
    #
    def best_stylesheets(*args)
      build_tags( Tension::CSS, *args )
    end

    # Determines the best JavaScripts to be included in a template based
    # on the current controller and action.
    #
    def best_javascripts(*args)
      build_tags( Tension::JS, *args )
    end

    private

    def build_tags(type, *args)
      options = args.extract_options!
      shared_path = options.delete(:shared) || asset_context.shared_assets[type].presence

      html = asset_for( type, "application", *args, options )

      if shared_path
        html << asset_for( type, shared_path, *args )
      end

      # action_asset = case type
      #   when Tension::CSS
      #     action_stylesheet
      #   when Tension::JS
      #     action_javascript
      # end

      # html << asset_for( type, action_asset.logical_path, *args, options )

      html.html_safe
    end

    def asset_for(type, path, *args)
      return nil if asset_context.nil?

      case type
        when Tension::CSS
          stylesheet_link_tag( path, *args )
        when Tension::JS
          javascript_include_tag( path, *args )
      end
    end
  end

end
