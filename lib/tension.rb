require 'tension/utils'
require 'tension/context'
require 'tension/controller'
require 'tension/helper'
require 'tension/environment'
require 'tension/railtie' if defined?(Rails)

module Tension
  CSS = "css".freeze
  JS  = "js".freeze
end
