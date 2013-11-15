require 'active_support/concern'

module Tension
  module Controller
    extend ActiveSupport::Concern

    included do
      # Make these methods available in helpers too.
      helper_method :asset_context, :action_javascript, :action_stylesheet

      class_attribute :_tension_assets, instance_accessor: false
      self._tension_assets = {}
    end


    module ClassMethods
      def include_assets(options)
        self._tension_assets[ Tension::CSS ] = options[:css]
        self._tension_assets[ Tension::JS ]  = options[:js]
      end
    end


    # Returns the Sprockets Asset for the current action's JavaScript
    # to be written into the template.
    #
    def action_javascript
      asset_context.js( request.symbolized_path_parameters[:action] )
    end

    # Returns the Sprockets Asset for the current action's stylesheet
    # to be written into the template.
    #
    def action_stylesheet
      asset_context.css( request.symbolized_path_parameters[:action] )
    end


    # Returns the Context for the current controller.
    #
    def asset_context
      find_asset_context( request.symbolized_path_parameters[:controller] )
    end

    # Proxy to Tension::Environment.find.
    #
    def find_asset_context(*args)
      Tension.environment.find_context(*args)
    end
  end
end
