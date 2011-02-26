set :application, "kuan"
set :repository,  "git@github.com:sjerrys/kuan.git"

set :scm, :git
set :deploy_to, "/var/www"
set :use_sudo, false

role :web, "kuandom.com"                                   # Your HTTP server, nginx
role :app, "kuandom.com"                          # This may be the same as your `Web` server
role :db,  "kuandom.com", :primary => true # This is where Rails migrations will run

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_release}/tmp/restart.txt}"
  end
end
