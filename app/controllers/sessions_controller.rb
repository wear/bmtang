# This controller handles the login/logout function of the site.    
  
class SessionsController < BaseController
  if AppConfig.closed_beta_mode
    skip_before_filter :beta_login_required
  end  
  
  def login_box 
    respond_to do |wants|
      wants.html {  }
      wants.js  { render_to_facebox(:partial => 'sessions/login_box') }
    end
  end     
  
  def index
    redirect_to :action => "new"
  end  
  
  # render new.rhtml
  def new
    redirect_to user_path(current_user) and return if current_user
    render :layout => 'beta' if AppConfig.closed_beta_mode
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      flash.now[:notice] = :thanks_youre_now_logged_in.l
      # current_user.track_activity(:logged_in)
      respond_to do |wants|
        wants.html { redirect_back_or_default(dashboard_user_path(current_user)) }
        wants.js { redirect_from_facebox(session[:return_to]) }
      end
    else
      flash.now[:error] = :uh_oh_we_couldnt_log_you_in_with_the_username_and_password_you_entered_try_again.l
      respond_to do |wants|
        wants.html { 
#        redirect_to teaser_path and return if AppConfig.closed_beta_mode        
        render :action => 'new' }
        wants.js { 
          render :update do |page|
                page.replace_html 'login-box', :partial => 'sessions/login_box' 
          end
           }
      end

    end
  end
  
  def openids
    openid_url = 'https://www.google.com/accounts/o8/id'
    authenticate_with_open_id(openid_url, {:required => [ 'email' ] }) do |result, identity_url, registration|
      case result.status
      when :missing
        failed_login "Sorry, the OpenID server couldn't be found"
      when :invalid
        failed_login "Sorry, but this does not appear to be a valid OpenID"
      when :canceled
        failed_login "OpenID verification was canceled"
      when :failed
        failed_login "Sorry, the OpenID verification failed"
      when :successful
        if registration.class.to_s == "OpenID::AX::FetchResponse"
          @email = registration['http://schema.openid.net/contact/email'].to_s 
        else       
          @email = registration['email'].to_s
        end                                         
        @user = User.find_or_initialize_by_email(@email)
        if @user.new_record?
          @user.login = @email
          @user.email = @email
          @user.save(false)
          @user.activate
        end    
       flash.now[:notice] = :thanks_youre_now_logged_in.l    
        self.current_user = @user
        successful_login    
        # Find (or create user) based on identity_url
        # Note that email is not set when the user has selected 'always remember' in the Google login page for subsequent logins
      end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = :youve_been_logged_out_hope_you_come_back_soon.l
    redirect_to new_session_path
  end
  
  protected
    def password_authentication(name, password)
      if @current_user = @account.users.authenticate(params[:name], params[:password])
        successful_login
      else
        failed_login "Sorry, that username/password doesn't work"
      end
    end

    def open_id_authentication
      authenticate_with_open_id do |result, identity_url|
        if result.successful?
          if @current_user = @account.users.find_by_identity_url(identity_url)
            successful_login
          else
            failed_login "Sorry, no user by that identity URL exists (#{identity_url})"
          end
        else
          failed_login result.message
        end
      end
    end
  
  
    #
    # If we want to get the GMail address for a user using Google Federated Login,
    # we need to work with AX attributes, not SReg attributes which is used by
    # default.
    #
    # To solve this Ax/SReg attribute problem we patch the OpenIdAuthentication
    # module to use AX attributes when talking to the Google OpenID server
    #
    # This patch is based on the source from github[1], January 4, 2009
    #
    # 1. http://github.com/rails/open_id_authentication/commits/master
    #
    module ::OpenIdAuthentication
      require 'openid/extensions/ax'

      private
      def add_simple_registration_fields(open_id_request, fields)
        if is_google_federated_login?(open_id_request)
          ax_request = OpenID::AX::FetchRequest.new
          # Only the email attribute is currently supported by google federated login
          email_attr = OpenID::AX::AttrInfo.new('http://schema.openid.net/contact/email', 'email', true)
          ax_request.add(email_attr)
          open_id_request.add_extension(ax_request)
        else
          sreg_request = OpenID::SReg::Request.new
          sreg_request.request_fields(Array(fields[:required]).map(&:to_s), true) if fields[:required]
          sreg_request.request_fields(Array(fields[:optional]).map(&:to_s), false) if fields[:optional]
          sreg_request.policy_url = fields[:policy_url] if fields[:policy_url]
          open_id_request.add_extension(sreg_request)
        end
      end

      def complete_open_id_authentication
        params_with_path = params.reject { |key, value| request.path_parameters[key] }
        params_with_path.delete(:format)
        open_id_response = timeout_protection_from_identity_server { open_id_consumer.complete(params_with_path, requested_url) }
        identity_url     = normalize_identifier(open_id_response.display_identifier) if open_id_response.display_identifier

        case open_id_response.status
        when OpenID::Consumer::SUCCESS
          if is_google_federated_login?(open_id_response)
            yield Result[:successful], params['openid.identity'], OpenID::AX::FetchResponse.from_success_response(open_id_response)
          else
            yield Result[:successful], identity_url, OpenID::SReg::Response.from_success_response(open_id_response)
          end
        when OpenID::Consumer::CANCEL
          yield Result[:canceled], identity_url, nil
        when OpenID::Consumer::FAILURE
          yield Result[:failed], identity_url, nil
        when OpenID::Consumer::SETUP_NEEDED
          yield Result[:setup_needed], open_id_response.setup_url, nil
        end
      end

      def is_google_federated_login?(request_response)
        return request_response.endpoint.server_url == "https://www.google.com/accounts/o8/ud"
      end
    end
    
    def successful_login
      session[:user_id] = @current_user.id
      redirect_to(root_url)
    end

    def failed_login(message)
      flash[:error] = message
      redirect_to(new_session_url)
    end

end
