class PagesController < ApplicationController
  respond_to :html, :js
  
  def home
    @title = "Home"
    if signed_in?
      @micropost = Micropost.new 
      if (params[:search] && params[:search].match(/^[\w+\s+\-.@]+$/i) ) or params[:search].blank?
          @feed_items = current_user.feed.search(params[:search]).page(params[:page])
          
        else
          flash.now[:error] = "Invalid characters used. Avoid using \, or \' or \" in search"
          @feed_items = current_user.feed.page(params[:page])
      end
    end
    
          respond_with(@feed_items) do |format|
          format.js {  
               render :layout => false
            }
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
