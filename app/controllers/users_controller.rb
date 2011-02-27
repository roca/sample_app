class UsersController < ApplicationController
  
  before_filter :authenticate, :except => [:new,:show,:create]
  before_filter :correct_user, :only => [:edit,:update]
  before_filter :admin_user,   :only => :destroy
  
  def index
    if (params[:search] && params[:search].match(/^[\w+\s+\-.@]+$/i) ) or params[:search].blank?
        @users = User.search(params[:search]).page(params[:page])
     else
        flash.now[:error] = "Invalid characters used. Avoid using \, or \' or \" in search"
        @users = User.page(params[:page])
     end
      @title = 'All users'
  end
  
  def new
    @user = User.new
    @title = "Sign up"
  end
  
  def show
      @user  = User.find(params[:id])
      if (params[:search] && params[:search].match(/^[\w+\s+\-.@]+$/i) ) or params[:search].blank?
          @microposts = @user.microposts.search(params[:search]).page(params[:page])
        else
          flash.now[:error] = "Invalid characters used. Avoid using \, or \' or \" in search"
          @microposts = @user.microposts.page(params[:page])
      end
      @title = @user.name
  end
  
  def following
    show_follow(:following)
  end
  
  def followers
    show_follow(:followers)
  end
  
  def show_follow(action)
      @title = action.to_s.capitalize
      @user = User.find(params[:id])
      @users = @user.send(action).page(params[:page])
      render 'show_follow'
 end
  
  
  def create
    @user = User.new(params[:user])
    if @user.save
      
      sign_in @user
      @user.deactivate

       UserMailer.send_password_request(@user).deliver
       flash.now[:success]= "A temporary activation token has been sent to #{@user.email}"
       render 'sessions/token'
       
     else
     @title = "Sign up"
     render 'new'
   end
  end
  
  def edit
    @title = "Edit user"
  end

  def update
     if @user.update_attributes(params[:user])
      redirect_to @user, :flash => { :success => "Profile updated." }
    else
      @title = "Edit user"
      render 'edit'
    end
   
  end

  def destroy
    @user.destroy
    redirect_to users_path, :flash => { :success => "User destroyed"}
  end
  
  
 private
 
 def correct_user
   @user =  User.find(params[:id])
   redirect_to root_path unless current_user?(@user)
 end
 
 def admin_user
   @user = User.find(params[:id])
   redirect_to root_path if !current_user.admin? || current_user?(@user)
 end

end
