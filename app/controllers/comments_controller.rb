class CommentsController < BaseController
  before_filter :login_required, :except => [:index]

  if AppConfig.allow_anonymous_commenting
    skip_before_filter :verify_authenticity_token, :only => [:create]   #because the auth token might be cached anyway
    skip_before_filter :login_required, :only => [:create]
  end

  uses_tiny_mce(:options => AppConfig.simple_mce_options, :only => [:index])

  cache_sweeper :comment_sweeper, :only => [:create, :destroy]

  def show
    @comment = Comment.find(params[:id])
    render :text => @comment.inspect
  end

  def index
  
    @commentable = comment_type.constantize.find(comment_id)

    #don't use the get_type, as we want the specific case where the user typed /User/username/comments
    redirect_to user_comments_path(params[:commentable_id]) and return if (params[:commentable_type] && params[:commentable_type].camelize == "User")    
      
    unless logged_in? || @commentable && @commentable.owner.profile_public?
      flash.now[:error] = :this_users_profile_is_not_public_youll_need_to_create_an_account_and_log_in_to_access_it.l
      redirect_to :controller => 'sessions', :action => 'new' and return
    end

    if @commentable

      @comments = @commentable.comments.recent.find(:all, :page => {:size => 10, :current => params[:page]})

      if @comments.to_a.empty?

        render :text => :no_comments_found.l_with_args(:type => comment_type.constantize) and return unless (comment_type == "User" || @commentable.user_id)
        
        if comment_type == "User"
          @user = @commentable
          @title = @user.login
          @back_url = user_path(@user)
        else comment_type != "User" 
          @user = @commentable.user
          @title = comment_title
          @back_url = url_for([@user, @commentable].compact)
        end

      else
        @user = @comments.first.recipient
        @title = comment_title
        @back_url = commentable_url(@comments.first)
      end
      
      respond_to do |format|
        format.html {
          render :action => 'index' and return
        }
        format.rss {
          @rss_title = "#{AppConfig.community_name}: #{@commentable.class.to_s.underscore.capitalize} Comments - #{@title}"
          @rss_url = comment_rss_link
          render_comments_rss_feed_for(@comments, @title) and return
        }
      end      
    end

    respond_to do |format|
      format.html {
        flash[:notice] = :no_comments_found.l_with_args(:type => comment_type.constantize)
        redirect_to :controller => 'base', :action => 'site_index' and return
      }
    end
  end

  def new
    @commentable = comment_type.constantize.find(comment_id)
    redirect_to commentable_comments_url(@commentable)
  end


  def create
    @commentable = comment_type.constantize.find(comment_id)
    @comment = Comment.new(params[:comment])
    @comment.recipient = @commentable.owner

    @comment.user_id = current_user.id if current_user
    @comment.author_ip = request.remote_ip #save the ip address for everyone, just because

    respond_to do |format|
      if (logged_in? || verify_recaptcha(@comment)) && @comment.save
        @commentable.add_comment @comment
        @comment.send_notifications

        flash.now[:notice] = :comment_was_successfully_created.l
        format.html {
          redirect_to commentable_url(@comment)
        }
        format.js {
          render :partial => 'comments/comment', :locals => {:comment => @comment, :highlighted => true}
        }
      else
        flash.now[:error] = :comment_save_error.l_with_args(:error => @comment.errors.full_messages.to_sentence)
        format.html {
          redirect_to :controller => comment_type.underscore.pluralize, :action => 'show', :id => comment_id
        }
        format.js{
          render :inline => flash[:error], :status => 500
        }
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    if @comment.can_be_deleted_by(current_user) && @comment.destroy
      flash.now[:notice] = :the_comment_was_deleted.l
    else
      flash.now[:error] = :comment_could_not_be_deleted.l
    end
    respond_to do |format|
      format.html { redirect_to users_url }
      format.js   {
        render :inline => flash[:error], :status => 500 if flash[:error]
        render :text => 'ok' if flash[:notice]
      }
    end
  end


  private
  
  def comment_type
    return "User" unless params[:commentable_type]
    params[:commentable_type].camelize
  end
  
  def comment_id
    params[:commentable_id] || params[:user_id]
  end
  
  def comment_link
    params[:commentable_id] ? comments_path(@commentable.class.to_s.underscore, @commentable.id) : user_comments_path(@user)
  end
  
  def full_comment_link
    "#{APP_URL}#{comment_link}"
  end
  
  def comment_rss_link
    params[:commentable_id] ? formatted_comments_path(@commentable.class.to_s.underscore, @commentable.id, :rss) : formatted_user_comments_path(@user, :rss)
  end
  
  def comment_title

    return @comments.first.commentable_name if @comments.first
  
    type = comment_type.underscore
    case type
      when 'user'
        @commentable.login
      when 'post'
        @commentable.title
      when 'clipping'
        @commentable.description || "Clipping from #{@user.login}"
      when 'photo'
        @commentable.description || "Photo from #{@user.login}"
      else 
        @commentable.class.to_s.humanize
    end  
  end
  
  def render_comments_rss_feed_for(comments, title)
    render_rss_feed_for(comments,
      { :class => @commentable.class,
        :feed => {  :title => title,
                    :link => full_comment_link },
        :item => { :title => :title_for_rss,
                   :description => :comment,
                   :link => Proc.new {|comment| commentable_url(comment)},
                   :pub_date => :created_at
                   }
      })
  end
  
end
