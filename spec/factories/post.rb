# -*- coding: utf-8 -*-
Factory.define :post do |p|
  # @user = Factory.build :user_unique
  # @blog = Factory.build :blog_unique
  #p.author { @user }
  #p.blog { @blog }
  
#  user = Factory.build :user_with_blogs
 # p.author { user }
  #p.blog { user.followings.first.blog }

 # user = Factory.build :user_unique
 # blog = Factory.build :blog_unique
 # following = Factory.build :following_lord
 # following.blog = blog
 # user.followings = [following]
 # p.author { user }
 # p.blog { blog }

end

Factory.define :text, :parent => :post, :class => :text do |p|
  p.title "哈哈哈"
  p.content "哈哈哈"
end

Factory.define :link, :parent => :post, :class => :link do |p|
  p.url "http://www.google.com"
  p.title "谷歌"
  p.content "this is content"
end

Factory.define :video, :parent => :post, :class => :video do |p|
  p.url "foo.swf"
end

Factory.define :pics, :parent => :post, :class => :pics do |p|
  p.content "this is pics content"
end

Factory.define :image do |p|
end

Factory.define :post2, :parent => :post, :class => :text do |p|
  p.title "哈哈哈"
  p.content "哈哈哈"
end

