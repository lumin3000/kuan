# -*- coding: utf-8 -*-
Factory.define :post do |p|
  p.association :author, :factory => :user_with_blogs
  p.association :blog, :factory => :blog_unique
end

Factory.define :text, :parent => :post, :class => :text do |p|
  p.title "哈哈哈"
  p.content "哈哈哈"
  p._type "Text"
end

Factory.define :link, :parent => :post, :class => :link do |p|
  p.url "http://www.google.com"
  p.title "谷歌"
  p.content "this is content"
  p._type "Link"
end

Factory.define :video, :parent => :post, :class => :video do |p|
  p.url "foo.swf"
  p._type "Video"
end

Factory.define :pics, :parent => :post, :class => :pics do |p|
  p.content "this is pics content"
  p.photos {|items| [items.association(:photo), items.association(:photo)]}
  p._type "Pics"
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

Factory.define :old_comments_notice, :parent => :comments_notice do |p|
  p.created_at 1.hour.ago
end
