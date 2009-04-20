class LandingController < BaseController
  layout 'landing' 
  caches_action :index
  
  def index
    @groups = Group.find(:all,:limit => 6,:include => 'asset')
  end
end
