class GroupsController < BaseController
  before_filter :login_required, :only => [:new, :edit, :create, :destroy, :join, :manage]
  before_filter :find_group, :except => [:index,:new,:create]
  layout 'groups' 
  
  def index
  end      
  
  def show
    @section = 'activity'
    @categories = Category.find(:all)
    get_recent_group_activity
  end 
  
  def new
    @group = Group.new
  end
  
  def edit
    respond_to do |wants|
      if current_user.becomes(LearnUser).is_mod_of?(@group)
        wants.html {  } 
      else 
        flash[:error] = 'you don have permission to do that!'
        wants.html {render :action => "show"}
      end
    end
  end
  
  def update
     respond_to do |wants|
       if current_user.becomes(LearnUser).is_mod_of?(@group)
         flash[:notice] = 'group was successfully updated!'
         @group.update_attributes(params[:group])
         wants.html { redirect_to @group }
       else                                          
         wants.html { render :action => "edit" }
         flash[:error] = 'you don have permission to do that!'
         wants.html {render :action => "show"}
       end                                                    
     end   
  end
  
  def create
    @group = Group.new params[:group]
    respond_to do |wants|
      if @group.save
        current_user.becomes(LearnUser).become_admin_of(@group)
        flash[:notice] = 'group was successfully created!'
        wants.html { redirect_to root_path }   
      else      
        wants.html { render :action => "new" }
      end
    end
  end
  
  def destroy
    respond_to do |wants|
    if @group.created_by == current_user.id
      @group.destroy
        flash[:notice] = 'group was successfully deleted!'                      
        wants.html { redirect_to root_path }
    else
        flash[:error] = 'you don have permission to do that!'    
        wants.html { redirect_to root_path }
      end
    end
  end
  
  def join 
    @user =  current_user.becomes(LearnUser)
    unless @user.membership(@group)
      if @group.member_auth
        @user.request_membership_of(@group)
        flash[:notice] = :group_request_send.l
      else
      @user.become_member_of(@group)   
      flash[:notice] = :group_join_succesfully.l :group => @group.name
    end
    else
      flash[:error] = :already_group_member.l
    end
    respond_to do |wants|
      wants.html { redirect_to @group }
    end
  end
  
  def members
    @members = @group.members.paginate  :page => params[:page], :order => 'created_at DESC'
  end  
  
  def managers
    @managers = @group.mods.paginate  :page => params[:page], :order => 'created_at DESC'
  end
  
  def edit_member
    @user = User.find(params[:user_id])
    @member = @user.becomes(LearnUser)
    respond_to do |wants|
      if current_user.becomes(LearnUser).is_mod_of?(@group)
        wants.html {  } 
      else 
        flash[:error] = 'you don have permission to do that!'
        wants.html {render :action => "show"}
      end
    end
  end
  
  def add_admin
    @user = User.find(params[:user_id])
    @member = @user.becomes(LearnUser) 
    @member.membership(@group).admin_role = true
   respond_to do |wants|
     wants.html { redirect_to members_group_path(@group) }
   end  
  end
  
  def pending_members
  end
  
  def reset_admin
    @user = User.find(params[:user_id])
    @member = @user.becomes(LearnUser)
    @member.membership(@group).admin_role = false
    respond_to do |wants|
      wants.html { redirect_to :action => "member" }
    end
  end     
  
  def accept
    @member = User.find params[:member_id]
    if @group.accept_member(@member) 
      flash[:notice] = :member_accepted.l
    else
      flash[:error] = :member_accept_error.l
    end
    respond_to do |wants|
      wants.html { redirect_to @group }
    end
  end 
  
  protected
  
  def find_group
    @group = Group.find(params[:id],:include => [:asset])
  end
  
  def get_recent_group_activity
    @recent_activity = @group.recent_activity(:size => 15, :current => 1)
  end
end
