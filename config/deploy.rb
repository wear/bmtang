set :application, 'elearning'
set :user, 'wear'

set :git_account, 'wear'

set :scm_passphrase,  Proc.new { Capistrano::CLI.password_prompt('Git Password:') }

role :web, '221.130.199.22'
role :app, '221.130.199.22'
role :db, '221.130.199.22', :primary => true

default_run_options[:pty] = true
set :repository,  "git@github.com:wear/bmtang.git"
set :scm, "git"
set :user, 'wear'

ssh_options[:forward_agent] = true
set :branch, "master"
set :deploy_via, :remote_cache
set :git_shallow_clone, 1
set :use_sudo, false
set :deploy_to, "/home/#{user}/sites/#{application}"    

namespace :deploy do
  
  task :default do
    transaction do
      update_code
      symlink
      copy_configs
      migrate
    end
    
    restart
  end
  
  task :copy_configs, :roles => :app do
   # run "cp -pf #{deploy_to}/to_copy/environment.rb #{current_path}/config/environment.rb"
    run "cp -pf #{release_path}/config/database.yml.example #{current_path}/config/database.yml"
    run "ln -s #{shared_path}/photos #{current_path}/public/photos"
  end                        
  
  desc "remove all cached file" 
  task :delete_cache, :roles => :app do
    run "rm -rf #{current_path}/public/index.html"
    run "rm -rf #{current_path}/public/cache"
  end
  
 desc "Restart Application"
 task :restart, :roles => :app do
   run "touch #{current_path}/tmp/restart.txt"
 end   
 
 desc "override start/stop Application to fit mod_rails" 
 [:start, :stop].each do |t|
     desc "#{t} task is a no-op with mod_rails"
     task t, :roles => :app do ; end
 end
 
 desc "Create asset packages for production" 
 task :after_update_code, :roles => [:web] do
   run <<-EOF
     cd #{release_path} && rake asset:packager:build_all
   EOF
 end

end
