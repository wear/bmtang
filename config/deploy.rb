set :application, 'elearning'
set :user, 'wear'

set :git_account, 'wear'

set :scm_passphrase,  Proc.new { Capistrano::CLI.password_prompt('zzzzzz') }

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
set :deploy_to, "/home/#{user}/site/#{application}"    

namespace :deploy do
  task :finishing_touches, :roles => :app do
   # run "cp -pf #{deploy_to}/to_copy/environment.rb #{current_path}/config/environment.rb"
    run "cp -pf #{deploy_to}/config/database.yml.example #{current_path}/config/database.yml"
  end
  
 desc "Restart Application"
 task :restart, :roles => :app do
   run "touch #{current_path}/tmp/restart.txt"
 end 

end
