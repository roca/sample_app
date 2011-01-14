class SessionsController < ApplicationController
  
  def new
    @title = "Sign in"
  end
  
  def create
    user = User.authenticate(params[:session][:email],
                               params[:session][:password])
                               
                                
      if user.nil?
       @forgot_password = true
       flash.now[:error] = "Invalid email/password combination"
       @title = "Sign in"
       render 'new'
        # Create an error message and re-render the signin form.
      else
        sign_in user
        redirect_back_or root_path #user
      end
   
  end
  
  def create_with_token
    
      email = params[:session][:email]
      user = User.where("lower(email) = ?",email.downcase).first
  
      user = User.authenticate_with_token(user, params[:session][:token])
                                 
     
       if user.nil?
        @invalid_token = true
        flash.now[:error] = "Invalid email/token combination"
        @title = "Sign in with token"
        render 'token'
       else
         sign_in user
         redirect_to edit_user_path(user)
       end                             
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end

  def password
    @title = "Forgotten password"
  end
  
  def token
    @title = "Sign in with token"
  end
  
  def send_password_request
    
     
        email = params[:session][:email]
          
        
        user = User.where("lower(email) = ?",email.downcase).first
        
        
        
        if user
          user.deactivate
          UserMailer.send_password_request(user).deliver
          flash.now[:success]= "A temporary activation token has been sent to #{user.email}"
          render 'token'
        else
          @title = "Forgotten password"
          flash.now[:error] = "This email does not exist in our database please try again!"
          render 'password'
        end
  end
 
end
