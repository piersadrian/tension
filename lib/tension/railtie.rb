require "tension"

module Tension
  require "rails"

  class Railtie < Rails::Railtie
    initializer "tension.asset_pipeline" do |app|
      ActiveSupport.on_load :rails do
        if !Rails.env.development? && !Rails.env.test?
          Rails.application.config.assets.precompile += Tension::Environment.collect_assets
        end
      end
    end
  end
end
