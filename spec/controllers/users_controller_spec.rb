require 'spec_helper'

describe UsersController do
  render_views
  
  describe "GET 'index'"   do
    
    describe "for non-signed-in users" do
      
      it "should deny access" do
        get :index 
        response.body.should redirect_to(signin_path)
      end
      
    end
  
    describe "for signed-in users" do
      
      before(:each) do
        @user = test_sign_in(Factory(:user))
        
        30.times do
          Factory(:user, :username => Factory.next(:username),:email => Factory.next(:email) )
        end
      end
      
       it "should be successfull" do
          get :index 
          response.should be_success
        end
        
        it "should have the right title" do
          get :index
          response.body.should have_selector("title", :text => 'All users')
        end
        
        it "should have an element for each user" do
          get :index
          User.page(1).each do |user|
            response.body.should have_selector("li", :text => user.name)
          end
        end
        
        
        it "should paginate users" do
                       get :index
                       response.body.should have_selector("nav.pagination")
                       response.body.should have_selector("span", :text => "1")
                       #response.body.should_not have_link("1")
                       response.body.should have_link("2")
                       response.body.should have_link("3")
                    end
        
         it "should have a enabled 'Prev' link on second page" do
             get :index, :page => 2
             response.body.should have_selector("nav.pagination")
             response.body.should have_selector("span", :text => "Prev")
             response.body.should have_link("Prev",:href => "/users")
          end
        
        it "should have a delete link for admins" do
           @user.toggle!(:admin)
           get :index
           User.page(1).each do |user|
             response.body.should     have_link("delete", :href => user_path(user)) unless @user == user
             response.body.should_not have_link("delete", :href => user_path(user)) unless @user != user
           end
        end
        
        it "should not have a delete link for non-admins" do
           get :index
           User.page(1).each do |user|
             response.body.should_not     have_link("delete", :href => user_path(user))
           end
        end
        
        
         it "should have search form " do
                get :index , :search => "omel"
                response.body.should have_selector( "form" , :method => "get", :action => "/users" ) do |form|
                  form.should     have_selector( "input", :type => "text",  :name => "search", :value => 'omel')
                  form.should     have_selector( "input", :type => "submit")
                end
         end
        
    end
    
  end
  
  describe "GET 'show'"    do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
    
    it "should have the right title" do
      get :show, :id => @user
      response.body.should have_selector("title", :text => @user.name)
    end
    
    it "should have the users name" do
      get :show, :id => @user
      response.body.should have_selector("td", :text => @user.name)
    end
    
    it "should have a profile image" do
      get :show, :id => @user
      response.body.should have_selector("td>img", :class => "gravatar")
    end
    
    it "should have the right URL" do
        get :show, :id => @user
        response.body.should have_selector("td>a",:text => user_path(@user),
                                             :href    => user_path(@user))
    end
  
    it "should show the user's microposts" do
      mp1 = Factory(:micropost, :user => @user , :content => "Foo Bar")
      mp2 = Factory(:micropost, :user => @user , :content => "Baz quux")
      get :show, :id => @user
      response.body.should have_selector("span.content",:text => mp1.content)
      response.body.should have_selector("span.content",:text => mp2.content)
    end
    
    it "should paginate microposts" do
       35.times { Factory(:micropost, :user => @user , :content => "foo") }
       get :show, :id => @user
       response.body.should have_selector("nav.pagination")
    end
    
     it "should display microposts count" do
          10.times { Factory(:micropost, :user => @user , :content => "foo") }
          get :show, :id => @user
          response.body.should have_selector("td.sidebar", :text => @user.microposts.count.to_s)
     end
     
     describe "when signed in as another user" do
       
        it "should be successfull" do
          test_sign_in(Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email)))
          get :show, :id => @user
          response.should be_success
        end
       
     end
     
     it "should have search form " do
             10.times { Factory(:micropost, :user => @user , :content => "foo") }
             get :show, :id => @user, :search => "omel"
             response.body.should have_selector( "form" , :method => "get", :action => user_path(@user) ) do |form|
               form.should     have_selector( "input", :type => "text",  :name => "search", :value => 'omel')
               form.should     have_selector( "input", :type => "submit")
             end
     end
     
     it "should have the right follower/following counts" do
             @other_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
             @user.follow!(@other_user)
             @user.should be_following(@other_user)
             get :show, :id => @user
             response.body.should have_link("1 following", :href => following_user_path(@user))
             response.body.should have_link("0 followers", :href => followers_user_path(@user))
     end
     
  end

  describe "GET 'new'"     do
    
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have the right title" do
      get :new
      response.body.should have_selector("title", :text => "Sign up")
    end
    
    
     it "should have new user form " do
         get :new
         response.body.should have_selector( "form" , :method => "post", :action => "/users" ) do |form|
           form.should have_selector("input", :type => "text",     :name => "user[name]")
           form.should have_selector("input", :type => "text",     :name => "user[email]")
           form.should have_selector("input", :type => "password", :name => "user[password_confirmation]")
           form.should have_selector("input", :type => "password", :name => "user[password]")
           form.should have_selector("input", :type => "submit")
         end
     end  
  end
  
  describe "POST 'create'" do
     
     describe "failure" do
       
       before(:each) do
        @attr = {:name                   => "", 
                 :username               => "",
                 :email                  => "",
                 :password               => "", 
                 :password_confirmation  => ""
               }
       end
       
       it 'should have the right title' do
         post :create , :user => @attr
         response.body.should have_selector("title", :text => "Sign up")
       end
       
       it "should render the 'new' page" do
          post :create , :user => @attr
          response.body.should render_template('new')
       end
        
       it "should not create a new user" do
         lambda do
           post :create , :user => @attr
         end.should_not change(User,:count)
       end
       
       
     end
      
     describe "Success" do

        before(:each) do
         @attr = {:name                   => "Romel Campbell", 
                  :username               => "desertfox",
                  :email                  => "RomelCampbell@gmail.com",
                  :password               => "foobar", 
                  :password_confirmation  => "foobar"
                }
        end

        it "should render the token page" do
          post :create , :user => @attr
          flash.now[:success].should =~ /A temporary activation token has been sent to #{@attr[:email]}/i
          response.body.should render_template('token')
        end
 
        it "should create a new user" do
           lambda do
             post :create , :user => @attr
           end.should change(User,:count).by(1)
        end
 
        it "should send an email and create a user activation token" do
          lambda do
            post :create , :user => @attr
          end.should change(ActivationToken,:count).by(1)
        end
        
        it "should sign the user in" do
            post :create , :user => @attr
            controller.should be_signed_in
        end
               
     end
  end
  
  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
      it "should be successful" do
        get :edit, :id => @user
        response.should be_success
      end
      
      it "should have the right title" do
        get :edit, :id => @user
        response.body.should have_selector("title", :text => 'Edit user')
      end
      
      it "should have a link to cahneg the Gravater" do
        get :edit, :id => @user
        response.body.should have_link("change",  :href => "http://gravatar.com/emails")
      end
     
      it "should have edit user form " do
             get :edit, :id => @user
             response.body.should have_selector( "form" , :method => "post", :action => "/users/#{@user.id}" ) do |form|
               form.should have_selector("input", :type => "text",     :name => "user[name]")
               form.should have_selector("input", :type => "text",     :name => "user[email]")
               form.should have_selector("input", :type => "password", :name => "user[password_confirmation]")
               form.should have_selector("input", :type => "password", :name => "user[password]")
               form.should have_selector("input", :type => "submit")
           end
       end
    
  end

  describe "PUT 'update'" do
    
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
  
     describe "failure" do
       
       before(:each) do
        @attr = { :name                   => "", 
                  :email                  => "",
                  :password               => "", 
                  :password_confirmation  => ""
                }
        end
        
          it "should render the 'edit' page" do
            put :update , :id => @user, :user => @attr
            page.should render_template('edit')
          end
          
          # it "should have the right title" do
          #    put :update , :id => @user, :user => @attr
          #    page.should have_css("title", :text => 'Edit user')
          #  end
      end
     
     describe "Success" do
       before(:each) do
       @attr = { :name                   => "New Name", 
                 :email                  => "user@example.org",
                 :password               => "barbaz", 
                 :password_confirmation  => "barbaz"
               }
       end
       
       it "should change the user attributes" do
          put :update , :id => @user, :user => @attr
          user = assigns(:user)
          @user.reload
          @user.name.should  == user.name
          @user.email.should == user.email
          @user.encrypted_password == user.encrypted_password
       end
       
       it 'should have a flash message' do
          put :update , :id => @user, :user => @attr
          flash[:success].should =~ /updated/
        end
       
     end
  end

  describe "authentication of edit/update actions" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "for non-signed-in users" do
      
      it "should deny access to 'edit'" do
        get :edit , :id => @user
        response.body.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
      
      it "should deny access to 'update'" do
        put :update , :id => @user, :user => {}
        response.body.should redirect_to(signin_path)
      end
      
    end
    
    describe "for signed-in users" do
      before(:each) do
        wrong_user = Factory(:user, :username => Factory.next(:username),:email => "user@example.net")
        test_sign_in(wrong_user)
      end
      
      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.body.should redirect_to root_path
      end
      
      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.body.should redirect_to root_path
      end
    end

  end

  describe "DELETE 'destroy'"  do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "as a non-signed-in user" do
      
      it "should deny access" do
        delete :destroy , :id => @user
        response.body.should redirect_to(signin_path)
      end
    end
    
    describe "as a non-admin user" do
      
      it "should protect the action" do
        test_sign_in(@user)
        delete :destroy , :id => @user
        response.body.should redirect_to root_path
      end
    end
    
    describe "as a admin user" do
      
      before(:each) do
        @admin = Factory(:user, :username => Factory.next(:username), :email => "admin@example.com" , :admin => true)
        test_sign_in(@admin)
      end
      
      it "should destroy the user" do
        lambda do
          delete :destroy , :id => @user
        end.should change(User,:count).by(-1)
      end
      
      it "should redirect to the users page" do
        delete :destroy , :id => @user
        flash[:success].should =~ /destroyed/i
        response.body.should redirect_to users_path
      end
      
      it "should not be able to destroy itself" do
        lambda do
          delete :destroy , :id => @admin
        end.should_not change(User,:count)
      end
      
    end
    
  end

  describe "following pages" do
  
    describe "when not signed in" do
      
      it "should protect 'following'" do
         get :following, :id => 1
         response.body.should redirect_to(signin_path)
      end
      
      it "should protect 'followers'" do
          get :followers, :id => 1
          response.body.should redirect_to(signin_path)
      end
    
    end
      
        
  end

  
end
