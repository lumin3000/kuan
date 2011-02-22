Factory.define :user do |user|
  user.name "Test user"
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
  f.auth "follower"
  f.association :blog
end
