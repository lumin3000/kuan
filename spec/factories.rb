# -*- coding: utf-8 -*-
Factory.define :user do |user|
  user.name "testuser"
  user.email "u1@k.com"
  user.password "foobar"
  user.password_confirmation "foobar"
end

Factory.sequence :email do |n|
  "people-#{n}@k.org"
end

Factory.define :blank_user do |user|
  user.name ""
  user.email ""
  user.password ""
  user.password_confirmation ""
end

Factory.define :blog do |blog|
  blog.uri "blog-uri"
  blog.title "blog title"
end

Factory.sequence :uri do |u|
  "bloguri-#{u}"
end

Factory.define :following do |f|
  f.auth "member"
  f.association :blog
end

Factory.define :text do |p|
  p.title "哈哈哈"
  p.content "哈哈哈"
end

Factory.define :link do |p|
  p.url "http://www.google.com"
  p.title "谷歌"
  p.content "this is content"
end

Factory.define :video do |p|
  p.url "foo.swf"
end

Factory.define :pics do |p|
  p.content "this is pics content"
  p.photos {|items| [items.association(:photo), items.association(:photo)]}
end

Factory.define :photo do |p|
  p.desc "this is photo desc"
  p.association :image
end

Factory.define :image do |p|
end
