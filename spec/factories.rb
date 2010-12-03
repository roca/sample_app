Factory.define :user do |user|
  user.name                   "Romel Campbell"
  user.email                  "RomelCampbell@gmail.com"
  user.password               "foobar"
  user.password_confirmation  "foobar"
end

Factory.sequence :email do |n|
   "person-#{n}@example.com"
end

Factory.sequence :token do |n|
   "#{Time.now.utc}---#{n}testtoken"
end

Factory.define :micropost do |micropost|
  micropost.content           "Foo Bar"
  micropost.association       :user
end

Factory.define :activation_token do |at|
  at.token             "Foo Bar"
  at.association       :user
end


