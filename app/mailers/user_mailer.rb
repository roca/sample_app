class UserMailer < ActionMailer::Base
  default :from => "RomelCampbell@gmail.com"
  
  def send_password_request(user)
     @user = user
     @activation_token = @user.activation_token || @user.create_activation_token({:token => Digest::SHA2.hexdigest("#{Time.now.utc}--#{user.email}")})
     
     mail(:to => "#{user.name} <#{user.email}>" , :subject => "Password request")
   end
  
end
