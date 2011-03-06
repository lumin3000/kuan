# -*- coding: utf-8 -*-
Factory.define :user do |user|
  user.name "testuser"
  user.email "u1@k.com"
  user.password "foobarbazbal"
  user.password_confirmation "foobarbazbal"
  user.followings []
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
  blog.uri "bloguri"
  blog.title "blog title"
  blog.custom_html "nothing would be rendered"
end

Factory.sequence :uri do |u|
  "bloguri-#{u}"
end

Factory.define :blog_unique, :parent => :blog do |blog|
  blog.uri { Factory.next(:uri) }
end

Factory.define :following do |f|
  f.auth "member"
  f.association :blog, :factory => :blog_unique
end

Factory.define :blog_primary, :parent => :blog_unique do |p|
  p.title "我的博客"
  p.primary true
end

Factory.define :blog_other, :parent => :blog_unique do |p|
  p.title "子博客"
  p.primary false
end

Factory.define :following_lord, :parent => :following do |p|
  p.auth "lord"
end

Factory.define :user_unique, :class => :user do |user|
  user.name "testuser"
  user.email { Factory.next(:email) }
  user.password "foobar"
  user.password_confirmation "foobar"
  #user.followings {|items| [items.association(:blog_primary), items.association(:blog_other)]}
end

Factory.define :user_with_blogs, :parent => :user_unique do |user|
  user.followings {|items| [items.association(:following_lord)]}
end

