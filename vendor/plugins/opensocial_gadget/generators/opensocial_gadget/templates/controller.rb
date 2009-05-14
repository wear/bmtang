class <%= class_name %>Controller < ApplicationController
  require 'opensocial'
  include OpenSocial::Auth

  skip_before_filter :verify_authenticity_token
  before_filter :opensocial_check_signature, :only => [:iframe]
  
  def index
    @prefs = OpenSocialGadget::Config.prefs
    respond_to do |format|
      format.xml
    end
  end
  
  def iframe
    url_params = {
      :action => 'redirect',
      :owner_id => params[:opensocial_owner_id],
      :viewer_id => params[:opensocial_viewer_id],
      :consumer_key => params[:oauth_consumer_key],
      :view_type => params[:id]
    }
    
    width = OpenSocialGadget::Config.views[url_params[:view_type]]['width']
    height = OpenSocialGadget::Config.views[url_params[:view_type]]['height']
    redirect_url = url_for url_params
    render :text => "<iframe width='#{width}' height='#{height}' frameborder='0' src='#{redirect_url}' />"
  end
  
  def redirect
    session[:opensocial_params] = {
      :owner_id => params[:owner_id],
      :viewer_id => params[:viewer_id],
      :consumer_key => params[:consumer_key],
      :view_type => params[:view_type]
    }
    redirect_to OpenSocialGadget::Config.views[params[:view_type]]['url']
  end
  
  private
  
  def opensocial_check_signature
    consumer_key = params[:oauth_consumer_key]
    secret = OpenSocialGadget::Config.keys[consumer_key]['secret'] if OpenSocialGadget::Config.keys[consumer_key]
    unless validate(consumer_key, secret)
      render :nothing => true, :status => :unauthorized
    end
  end
end
