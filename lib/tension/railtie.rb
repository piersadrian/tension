require 'tension'

module Tension
  require 'rails'

  class Railtie < Rails::Railtie

    initializer "tension.add_assets_to_precompile_list" do |app|
      ActionView::Base.send(:include, Tension::Helper)
      ActionController::Base.send(:include, Tension::Controller)

      Tension.environment = Tension::Environment.new('public/assets')

      Rails.application.config.assets.precompile << lambda do |path, filename|
        Tension.environment.precompilation_needed?(path)
      end
    end

  end
end
