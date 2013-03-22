require 'active_support/ordered_options'

require 'tension/environment'
require 'tension/railtie' if defined?(Rails)
require 'tension/tension_helper'

module Tension
  def self.load_assets!
    !!Tension::Environment.asset_map
  end

  # def self.config
  #   @config ||= begin
  #     config = ActiveSupport::OrderedOptions.new

  #     config.enabled = !Rails.env.development? && !Rails.env.test?

  #     config
  #   end
  # end
end
