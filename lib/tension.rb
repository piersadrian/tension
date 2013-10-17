require 'tension/utils'
require 'tension/context'
require 'tension/controller'
require 'tension/helper'
require 'tension/environment'
require 'tension/version'
require 'tension/railtie' if defined?(Rails)

module Tension
  CSS = "css".freeze
  JS  = "js".freeze

  def self.environment
    @@environment
  end

  def self.environment=(env)
    @@environment = env
  end
end
