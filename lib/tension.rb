require 'tension/environment'
require 'tension/railtie' if defined?(Rails)
require 'tension/tension_helper'

module Tension
  def self.load_assets!
    !!Tension::Environment.asset_map
  end
end
