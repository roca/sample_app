


ActionMailer::Base.delivery_method = :smtp


ActionMailer::Base.smtp_settings = { 
  :address => "localhost", 
  :port => 26, 
  :domain => "romelcampbell.com", 
  :user_name => "roca@romelcampbell.com", 
  :password => "86XuDSMc", 
  :authentication  => :login
}

# ActionMailer::Base.smtp_settings = { 
#   :address => "smtp.gmail.com", 
#   :port => 587, 
#   :domain => "RomelCampbell.com", 
#   :authentication => :plain, 
#   :user_name => "RomelCampbell@gmail.com", 
#   :password => "g00gl3m81l"
# }
# 

ActionMailer::Base.default_url_options[:host] = "localhost:3000"

