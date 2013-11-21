require 'active_support/concern'

module Tension
  module Controller
    extend ActiveSupport::Concern

    included do
      # Make these methods available in helpers too.
      helper_method :asset_context, :action_javascript, :action_stylesheet
    end


    module ClassMethods
      def include_assets(options)
        Tension.environment.controllers[ self.name.underscore ] = {
          Tension::CSS => options[:css],
          Tension::JS  => options[:js]
        }
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
