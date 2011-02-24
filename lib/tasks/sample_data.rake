namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:drop'].invoke
    make_users_and_blogs
    make_followings
  end

  desc "db:drop might be a better name for this"
  task :purge => :environment do
    User.db.collections.each do |c|
      begin
        c.drop
      rescue
      end
    end
  end

  desc "reload seed data"
  task :reset => :environment do
    Rake::Task['db:purge'].invoke
    Rake::Task['db:seed'].invoke
  end
end

def make_users_and_blogs
  50.times do |n|
    user = User.create!(:name => "lilu-#{n}",
                        :email => "lilu-#{n}@k.org",
                        :password => "password",
                        :password_confirmation => "password")
    user.create_primary_blog!
    3.times do |m|
      blog = Blog.create!(:title => "title-founder-#{n}-#{m}",
                          :uri => "uri#{n}founder#{m}")
      user.follow! blog, "founder"
    end
  end
end

def make_followings
  User.all[1..10].each do |u|
    Blog.all[1..10].each {|b| u.follow! b, "follower"}
  end
end
