# -*- coding: utf-8 -*-
Factory.define :c_user, :class => :user do |user|
  user.name "testuser"
  user.email Factory.next(:email)
  user.password "foobar"
  user.password_confirmation "foobar"
  user.followings {|items| [items.association(:blog_primary), items.association(:blog_other)]}
end

Factory.define :c_blog_primary, :class => :blog do |p|
  p.uri Factory.next(:uri)
  p.title "我的博客"
  p.primary true
end

Factory.define :c_blog_other, :class => :blog do |p|
  p.uri Factory.next(:uri)
  p.title "子博客"
  p.primary false
end

Factory.define :c_following_lord, :parent => :following do |p|
  p.auth "lord"
  p.association :blog
end
