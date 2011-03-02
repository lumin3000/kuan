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

Factory.define :blog_primary, :class => :blog do |p|
  p.uri Factory.next(:uri)
  p.title "我的博客"
  p.primary true
end

Factory.define :blog_other, :class => :blog do |p|
  p.uri Factory.next(:uri)
  p.title "子博客"
  p.primary false
end

Factory.define :following_lord, :parent => :following do |p|
  p.auth "lord"
  p.association :blog
end

Factory.define :user2, :class => :user do |user|
  user.name "testuser"
  user.email Factory.next(:email)
  user.password "foobar"
  user.password_confirmation "foobar"
  user.followings {|items| [items.association(:blog_primary), items.association(:blog_other)]}
end
