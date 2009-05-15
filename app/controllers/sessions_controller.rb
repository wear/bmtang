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
  
  def connect
   # params[:fname] is a trigger by which we identify the right request
   if (params[:fname]=='_opener') 

     jsoned = params[:session]
     data = JSON.parse(jsoned) # data is sent in JSON, we need to parse it
     session[:connect] = data

 	# look for a user based on the facebook_uid supplied by login
     user = User.find_by_facebook_uid(data['uid'])


     if (!user)
       # create a new dummy user for the Facebook User if not present
       # if we want users to be able to log in without Facebook Connect
       # then it would be a good idea to allow them the change these details

       user = User.new
       user.facebook_uid = data['uid']
       user.login = 'fb_' + data['uid']
       user.password = Time.now.to_i.to_s
       user.password_confirmation = user.password         

       user.email = data['uid'] + '@users.facebook.com'
       user.save!
     end

 	# log the user in
     self.current_user= user

   end
   render :layout => false
   # render the cross-domain communication channel
  end
  

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = :youve_been_logged_out_hope_you_come_back_soon.l
    redirect_to new_session_path
  end

end
