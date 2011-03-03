# -*- coding: utf-8 -*-
Factory.define :post do |p|
  user = Factory.build :user2
  p.blog { user.followings.first }
  p.author { user }
  #p.association :blog, :factory => :blog_primary
  #p.association :author, :factory => :user2
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

Factory.define :comment do |p|
  p.content 'this is a comment'
  p.association :author, :factory => :user
end
