namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    User.delete_all
    User.create!(:name => "lilu",
                 :email => "lilu@k.org",
                 :password => "foobar",
                 :password_confirmation => "foobar")
    99.times do |n|
      User.create!(:name => "lilu-#{n+1}",
                   :email => "lilu-#{n+1}@k.org",
                   :password => "password",
                   :password_confirmation => "password")
    end
  end
end
