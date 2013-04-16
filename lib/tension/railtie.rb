require 'tension'

module Tension
  require 'rails'

  class Railtie < Rails::Railtie
    initializer "tension.add_assets_to_precompile_list" do |app|

      if app.config.cache_classes
        app.reload_routes!
        Tension::Environment.eager_load!
      end

      ActionView::Base.send(:include, Tension::Helper)
      ActionController::Base.send(:include, Tension::Controller)

      Rails.application.config.assets.precompile << lambda do |path, filename|
        Tension::Environment.precompilation_needed?(path)
      end

    end
  end
end
