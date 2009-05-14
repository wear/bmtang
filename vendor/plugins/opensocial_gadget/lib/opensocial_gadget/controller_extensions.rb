module OpenSocialGadget
  module ControllerExtensions
    
    def opensocial_params
      session[:opensocial_params]
    end

    def opensocial_prefs
      Config.prefs
    end

    def opensocial_view
      Config.views[opensocial_params[:view_type]]
    end

    def opensocial_connection
      if @connection == nil
        @connection = Connection.new(opensocial_params[:consumer_key], opensocial_params[:owner_id])
      end
      @connection
    end
  end
end