# -*- coding: utf-8 -*-
Factory.define :post do |p|
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

Factory.define :audio, :parent => :post, :class => :audio do |p|
  p.song_id "123456"
  p._type "Audio"
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
