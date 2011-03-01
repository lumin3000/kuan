set :application, "kuan"
set :repository,  "git@github.com:sjerrys/kuan.git"

set :scm, :git
set :deploy_to, "/var/kuan"
set :use_sudo, false
set :ssh_options, {:forward_agent => true}

role :web, "kuandao.com"                                   # Your HTTP server, nginx
role :app, "kuandao.com"                                   # This may be the same as your `Web` server
role :db,  "kuandao.com", :primary => true                 # This is where Rails migrations will run

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
  
  task :stop do ; end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :sass do
    run "cd #{current_path} && /usr/local/rvm/gems/ruby-1.9.2-p180/bin/rake RAILS_ENV=production sass:build"
  end
end

namespace :logs do
  task :watch do
    stream("tail -f #{current_path}/log/production.log")
  end
end

before("deploy:restart", "deploy:sass") 
