require 'active_support/concern'

module Tension

  # Tagger is included in ActionView::Helpers so it can be called from
  # templates and layouts.
  module TensionHelper
    extend ActiveSupport::Concern

    def asset_for type, *args
      controller = request.params[:controller]
      action     = request.params[:action]

      asset = Tension::Environment.asset_map[ controller ][ action ][ type.to_s ]

      include_method = case type
      when :js
        :javascript_include_tag
      when :css
        :stylesheet_link_tag
      end

      send( include_method, asset.logical_path, *args ) unless asset.nil?
    end
  end

end
