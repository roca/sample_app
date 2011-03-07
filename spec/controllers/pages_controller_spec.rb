require 'spec_helper'

describe PagesController do
  render_views
  
  before(:each) do
    @base_title = "Ruby on Rails Tutorial Sample App"
  end
  
  

  describe "GET 'home'" do
    
    
    it "should have a mobile_device? methond" do
      get 'home', :mobile => 0.to_s
      controller.should_not be_mobile_device
      response.should have_selector('a', :content => 'Mobile Site')
    end

    it "should have a mobile_device? methond" do
      get 'home', :mobile => 1.to_s
      controller.should be_mobile_device
      response.should have_selector('a', :content => 'Full Site')
    end


    
  describe "when not signed in" do
      
      it "should be successful" do
        get 'home'
        response.should be_success
      end

      it "should have the right title" do 
        get 'home' 
        response.should have_selector("title", 
              :content => @base_title + " | Home")
      end
      
      it "should have a non-blank body" do
       get 'home'
       response.body.should_not =~ /<body>\s*<\/body>/
      end
  end
  
  describe "when signed in" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        other_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
        other_user.follow!(@user)
      end  
      
      it "should have the right follower/following counts" do
         get 'home'
         response.should have_selector('a',:href => following_user_path(@user),
                                           :content => '0 following')
         response.should have_selector('a',:href => followers_user_path(@user),
                                           :content => '1 follower')
      end
      
      it "should have search form " do
             get 'home' , :search => "omel"
             response.should have_selector( "form" , :method => "get", :action => root_path ) do |form|
               form.should     have_selector( "input", :type => "text",  :name => "search", :value => 'omel')
               form.should     have_selector( "input", :type => "submit")
             end
      end
   
  end  
  
  end
  
  describe "GET 'contact'" do
    it "should be successful" do
      get 'contact'
      response.should be_success
    end
    
    it "should have the right title" do 
      get 'contact' 
      response.should have_selector("title", 
            :content => @base_title + " | Contact")
    end
  end
  
  describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      response.should be_success
    end
    
    it "should have the right title" do 
      get 'about' 
      response.should have_selector("title", 
            :content => @base_title + " | About")
    end
  end
  

  describe "GET 'help'" do
    it "should be successful" do
      get 'help'
      response.should be_success
    end
    
    it "should have the right title" do 
      get 'help' 
      response.should have_selector("title", 
            :content => @base_title + " | Help")
    end
  end

end
