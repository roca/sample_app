class MicropostsController < ApplicationController
  
  before_filter :authenticate, :only => [:create, :destroy]
  before_filter :authorized_user, :only => [:destroy]
  
  
  def create
   
    recipient_match = params[:micropost][:content].match(/^\s*@\w+/)
    
     
    if recipient_match
       recipient_username = recipient_match[0]
       recipient_username.lstrip!
       recipient_username.slice!("@")
       recipient = User.find_by_username(recipient_username)
       params[:micropost][:in_reply_to] = recipient.id if recipient
    end
    
    
    
    @micropost = current_user.microposts.build(params[:micropost])
    
    
    if @micropost.save
      if recipient_username && recipient.nil?
        flash.now[:error] = "User with username:#{recipient_username} does not exist!"
      end
      redirect_to root_path, :flash => { :success => "Micropost created!" }
    else
      @feed_items = []
      render "pages/home"
    end

  end
  
  def destroy
    @micropost.destroy
    redirect_to root_path, :flash => {:success => "Micropost deleted!"}
  end
  
  private
  
  def authorized_user
    
    @micropost = Micropost.find(params[:id])
    redirect_to root_path unless current_user?(@micropost.user)
    
  end
end