class PagesController < ApplicationController
  def home
    @title = "Home"
    if signed_in?
      @micropost = Micropost.new 
      if (params[:search] && params[:search].match(/^[\w+\s+\-.@]+$/i) ) or params[:search].blank?
          @feed_items = current_user.feed.search(params[:search]).paginate(:page => params[:page])
        else
          flash.now[:error] = "Invalid characters used. Avoid using \, or \' or \" in search"
          @feed_items = current_user.feed.paginate(:page => params[:page])
      end
      
    end
  end

  def  contact
    @title = "Contact"
  end
  
  def about
    @title = "About"
  end
  
  def help
    @title = "Help"
  end
  
  
end
