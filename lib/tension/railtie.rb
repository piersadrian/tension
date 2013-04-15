require 'tension'

module Tension
  require 'rails'

  class Railtie < Rails::Railtie
    initializer "tension.add_assets_to_precompile_list" do |app|
      ActiveSupport.on_load :after_initialize do

        if app.config.cache_classes
          app.reload_routes!
          Tension::Environment.eager_load!
        end

        ActionView::Base.send(:include, Tension::Helper)
        ActionController::Base.send(:include, Tension::Controller)

        app.config.assets.precompile << lambda do |path, filename|
          Tension::Environment.asset_paths.include?( filename )
        end

      end
    end
  end
end
