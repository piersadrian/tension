require 'active_support/concern'

module Tension
  module Controller
    extend ActiveSupport::Concern

    def action_assets
      controller = request.symbolized_path_parameters[:controller]
      action     = request.symbolized_path_parameters[:action]

      Tension::Environment.find( controller, action )
    end

    def assets
      Tension::Environment
    end
  end
end
