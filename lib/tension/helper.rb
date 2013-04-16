require 'active_support/concern'

module Tension

  # Helper is included in ActionView::Helpers so it can be called from
  # templates and layouts.
  module Helper
    extend ActiveSupport::Concern

    # Determines the best stylesheet to be included in a template based
    # on the current controller and action.
    #
    def best_stylesheet(*args)
      asset_for( Tension::CSS, *args )
    end

    # Determines the best JavaScript to be included in a template based
    # on the current controller and action.
    #
    def best_javascript(*args)
      asset_for( Tension::JS, *args )
    end

    private

    def asset_for(type, *args)
      controller = request.symbolized_path_parameters[:controller]
      action     = request.symbolized_path_parameters[:action]

      asset = Tension::Environment.find( controller ).send( action, type )

      include_method = case type.to_s
      when "js"
        :javascript_include_tag
      when "css"
        :stylesheet_link_tag
      end

      send( include_method, asset.logical_path, *args )
    end
  end

end
