# -*- coding: utf-8 -*-
Factory.define :post do |p|
  p.association :blog
  p.association :user
end

Factory.define :text, :parent => :post do |p|
  p.title "哈哈哈"
  p.content "哈哈哈"
end

Factory.define :link, :parent => :post do |p|
  p.url "http://www.google.com"
  p.title "谷歌"
  p.content "this is content"
end

Factory.define :video, :parent => :post do |p|
  p.url "foo.swf"
end

Factory.define :pics, :parent => :post do |p|
  p.content "this is pics content"
  p.photos {|items| [items.association(:photo), items.association(:photo)]}
end

Factory.define :photo do |p|
  p.desc "this is photo desc"
  p.association :image
end

Factory.define :image do |p|
end