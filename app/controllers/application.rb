# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include LocalizedApplication  
  include FaceboxRender 
  before_filter :set_facebook_session
  helper_method :facebook_session
  

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'ed16fd8e85054eb9233d5e576635f758'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password 
  
  def render_403
    @group = nil
    render :template => "common/403", :layout => !request.xhr?, :status => 403
    return false
  end
    
  def render_404
    render :template => "common/404", :layout => !request.xhr?, :status => 404
    return false
  end
  
  def render_wiki_missing
    render :template => "common/wiki_missing", :layout => !request.xhr?, :status => 404
    return false
  end
  
  def render_error(msg)
    flash.now[:error] = msg
    render :text => '', :layout => !request.xhr?, :status => 500
  end    
  
  def per_page_option
    per_page = nil
    per_page_options_array = AppConfig.per_page_options.split(%r{[\s,]}).collect(&:to_i).select {|n| n > 0}.sort
    if params[:per_page] && per_page_options_array.include?(params[:per_page].to_s.to_i)
      per_page = params[:per_page].to_s.to_i
      session[:per_page] = per_page
    elsif session[:per_page]
      per_page = session[:per_page]
    else
      per_page = per_page_options_array.first || 25
    end
    per_page
  end
  
end
