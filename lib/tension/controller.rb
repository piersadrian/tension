require 'active_support/concern'

module Tension
  module Controller
    extend ActiveSupport::Concern

    included do
      # Make these methods available in helpers too.
      helper_method :asset_context, :action_javascript, :action_stylesheet
    end

    # Returns the Context for the current controller.
    #
    def asset_context
      find_asset_context( request.path_parameters['controller'] )
    end

    # Returns the Sprockets Asset for the current action's JavaScript
    # to be written into the template.
    #
    def action_javascript
      asset_context.js( request.path_parameters['action'] )
    end

    # Returns the Sprockets Asset for the current action's stylesheet
    # to be written into the template.
    #
    def action_stylesheet
      asset_context.css( request.path_parameters['action'] )
    end

    # Proxy to Tension::Environment.find.
    #
    def find_asset_context(*args)
      Tension::Environment.find(*args)
    end
  end
end
