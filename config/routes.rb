ActionController::Routing::Routes.draw do |map|
  map.connect '/xiaonei.xml', :controller => 'xiaonei', :action => 'index', :format => 'xml'
  map.resources :bookmarks


  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
  map.root :controller => "landing"
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.resources :posts, :path_prefix => '/group/:group_id/category/:category_id/users/:user_id',:name_prefix => 'group_'   
  map.resources :groups,:member => { :join => :get,:members => :get,:activity => :get,:pending_members => :get, :managers => :get, } do |group|
    group.resource :wiki,:member => {:page => :get,:preview => :put, :annotate => :get,:new_page => :get,
      :create_page => :post, :protect => :post, :rename => [:get,:post], :history => :get, :diff => :get, :special => :get, :page_list => :get }
    group.resources :bookmarks
  end                                                                                                                      
  map.login_box '/login_box', :controller => 'sessions', :action => 'login_box'
  map.group_member '/groups/:id/members/:user_id',:controller => 'groups', :action => 'member'
  map.edit_group_member '/groups/:id/members/:user_id/edit',:controller => 'groups', :action => 'edit_member'
  map.update_group_member '/groups/:id/members/:user_id/update',:controller => 'groups', :action => 'update_member'
  map.group_category '/groups/:id/category/:category_id', :controller => 'categories', :action => 'show'
  map.accpet_pending_group_member '/groups/:id/members/:user_id/accept', :controller => 'groups', :action => 'accept'
  map.add_group_admin '/groups/:id/members/:user_id/add_admin', :controller => 'groups', :action => 'add_admin'
  map.kick_group_member '/groups/:id/members/:user_id/kick', :controller => 'groups', :action => 'kick'   
  map.reset_group_admin 'groups/:id/:members/:user_id/reset_admin', :controller => 'groups', :action => 'reset_admin'
  map.comatose_admin "admin/cms"
  map.comatose_about  "about",  :index=>'about',:layout => 'application'
  map.comatose_about  "faq",  :index=>'faq',:layout => 'application'
  map.from_plugin :community_engine 
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
