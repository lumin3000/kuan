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

  p.association :author, :factory => :user_with_blogs
  p.association :blog, :factory => :blog_unique
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
  p.photos {|items| [items.association(:photo), items.association(:photo)]}
end

Factory.define :photo do |p|
  p.desc "this is photo desc"
  p.association :image
end

Factory.define :image do |p|
end

Factory.define :post2, :parent => :post, :class => :text do |p|
  p.title "哈哈哈"
  p.content "哈哈哈"
end

Factory.define :comment do |p|
  p.content 'this is a comment'
end

Factory.define :comments_notice do |p|
  p.unread true
  p.association :post
end

Factory.define :read_comments_notice, :parent => :comments_notice do |p|
  p.unread false
end
