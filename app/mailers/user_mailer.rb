class UserMailer < ActionMailer::Base
  default :from => "RomelCampbell@gmail.com"
  
  def send_password_request(user)
     @user = user
     mail(:to => "#{user.name} <#{user.email}>" , :subject => "Password request")
   end
  
end
