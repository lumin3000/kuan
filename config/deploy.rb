$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"
require 'bundler/capistrano'
set :rvm_ruby_string, 'default'

set :application, "kuan"
set :whenever_command, "bundle exec whenever"
set :whenever_update_flags, "--write-crontab kuan --set environment=production"
require "whenever/capistrano"

set :repository,  "git@github.com:sjerrys/kuan.git"
set :scm, :git
set :user, "kuandev"
set :ssh_options, {:forward_agent => true}
set :deploy_via, :remote_cache
set :deploy_to, "/var/kuan"
set :use_sudo, false

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
    run "cd #{current_release} && rake RAILS_ENV=production sass:build"
  end

  task :jammit do
    run "cd #{current_release} && bundle exec jammit"
  end
end

# namespace :logs do
#   task :watch do
#     stream("tail -f #{current_path}/log/production.log")
#   end
# end

before("deploy:symlink", "deploy:sass")
before("deploy:symlink", "deploy:jammit") 
