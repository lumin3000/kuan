namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    User.delete_all
    99.times do |n|
      user = User.create!(:name => "lilu-#{n}",
                   :email => "lilu-#{n}@k.org",
                   :password => "password",
                   :password_confirmation => "password")
      blog = Blog.new(:title => "title-lord-#{n}",
               :uri => "urilord#{n}")
      blog.primary = true
      blog.save!
      user.follow Following.new(:blog => blog, :auth => "lord")
      3.times do |m|
        blog = Blog.create!(:title => "title-founder-#{n}-#{m}",
               :uri => "uri#{n}founder#{m}")
        user.follow Following.new(:blog => blog, :auth => "founder")
      end
    end
  end
end
