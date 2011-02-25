# -*- coding: utf-8 -*-
Factory.define :blog_primary, :parent => :blog do |p|
  p.uri "myuri"
  p.title "我的博客"
  p.primary true
end
Factory.define :blog_other, :parent => :blog do |p|
  p.uri "myuri2"
  p.title "子博客"
  p.primary false
end

Factory.define :following_lord, :parent => :following do |p|
  p.auth "lord"
  p.association :blog
end
