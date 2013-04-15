require 'active_support/concern'

module Tension

  # Helper is included in ActionView::Helpers so it can be called from
  # templates and layouts.
  module Helper
    extend ActiveSupport::Concern

    def best_stylesheet(*args)
      asset_for( Tension::CSS, *args )
    end

    def best_javascript(*args)
      asset_for( Tension::JS, *args )
    end

    private

    def asset_for(type, *args)
      controller = request.params[:controller]
      action     = request.params[:action]

      asset = Tension::Environment.find( controller, action ).send( type )

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
