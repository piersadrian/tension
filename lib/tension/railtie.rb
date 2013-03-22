require "tension"

module Tension
  require "rails"

  class Railtie < Rails::Railtie
    initializer "tension.add_assets_to_precompile_list" do |app|
      ActiveSupport.on_load :after_initialize do

        Rails.application.reload_routes!
        Tension.load_assets!

        ApplicationHelper.send(:include, Tension::TensionHelper)

        Rails.application.config.assets.precompile << lambda do |path, filename|
          Tension::Environment.asset_paths.include?( filename )
        end

      end
    end
  end
end
