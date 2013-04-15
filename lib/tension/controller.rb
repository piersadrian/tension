require 'active_support/concern'

module Tension
  module Controller
    extend ActiveSupport::Concern

    def assets
      Tension::Environment
    end
  end
end
