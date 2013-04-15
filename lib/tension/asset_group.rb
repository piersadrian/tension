module Tension
  class AssetGroup

    class << self
      # Builds a valid routing Path.
      def path_for(key, action = nil)
        if key.match( path_regex )
          return key

        elsif key.include?("#")
          key, action = key.split("#") 
        end

        unless key.try(:match, controller_regex) && action.try(:match, action_regex)
          raise ArgumentError, "[Tension] Couldn't build valid controller path!"
        end

        "#{ key }##{ action }"
      end

      # Matches strings like "blog/comments#show".
      def path_regex
        /([\w\/]+[^#])#(\w+)/
      end

      # Matches strings like "blog/comments".
      def controller_regex
        /([\w\/]+[^#])/
      end

      # Matches strings like "show".
      def action_regex
        /(\w+)/
      end
      
      def global_asset(type)
        assets[ "application.#{type}" ]
      end

      def assets
        Rails.application.assets
      end
    end


    attr_reader :controller, :action

    def initialize(key, action = nil)
      @controller, @action = self.class.path_for( key, action ).split("#")
    end

    def css
      best_asset( Tension::CSS )
    end

    def js
      best_asset( Tension::JS )
    end

    def action_asset(type)
      self.class.assets[ "#{controller}/#{action}.#{type}" ]
    end

    def controller_asset(type)
      self.class.assets[ "#{controller}_common.#{type}" ]
    end

    private

    def best_asset(type)
      action_asset(type) || controller_asset(type) || self.class.global_asset(type)
    end

    def method_missing(method_sym, *args)
      degree, type = method_sym.to_s.split("_")
      asset_method = "#{degree}_asset"

      respond_to?(asset_method) ? send(asset_method, type) : super
    end

  end
end
