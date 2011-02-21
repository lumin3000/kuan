Factory.define :user do |user|
  user.name "Test user"
  user.email "u1@k.com"
  user.password "foobar"
  user.password_confirmation "foobar"
end

Factory.define :blank_user do |user|
  user.name ""
  user.email ""
  user.password ""
  user.password_confirmation ""
end
