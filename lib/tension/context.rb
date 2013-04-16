module Tension
  class Context
    attr_reader :controller, :action

    def initialize(controller_path)
      @controller = "#{ controller_path }_controller".classify.constantize
    end

    # Locates the best stylesheet for the given action name. Aliased as,
    # for example, `#index( Tension::CSS )` or `#show(:css)`.
    #
    def css(action)
      best_asset( action, Tension::CSS )
    end

    # Locates the best JavaScript for the given action name. Aliased as,
    # for example, `#index( Tension::JS )` or `#show(:js)`.
    #
    def js(action)
      best_asset( action, Tension::JS )
    end

    # Returns the action-level asset for the given action name and type,
    # or nil.
    #
    def action_asset(action, type)
      Tension::Utils.find_asset( controller: controller.controller_path, action: action, type: type )
    end

    # Returns the controller-level asset for the given type, or nil.
    #
    def controller_asset(type)
      Tension::Utils.find_asset( controller: controller.controller_path, type: type )
    end

    # Returns the global asset for the given type (application.{css,js}).
    #
    def global_asset(type)
      Tension::Utils.global_asset(type)
    end

    def has_action?(action_name)
      controller.action_methods.include?(action_name)
    end


    private

    # Locates the best asset for the given action name and type.
    #
    def best_asset(action, type)
      action_asset(action, type) || controller_asset(type) || global_asset(type)
    end

    def method_missing(method_sym, *args)
      action = method_sym.to_s
      type   = args.first

      if has_action?(action)
        best_asset(action, type)
      else
        super
      end
    end

  end
end
