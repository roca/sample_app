require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'new'" do
    
    
    it "should be successful" do
      get :new
      response.should be_success
    end
   
    
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign in")
    end
    
    it "should not have a link for forgotten password page" do
        get :new
        response.should_not have_selector("a", :href => password_sessions_path ,  :content => "Forgot your password?")
    end
    
    it "should have new form " do
          get :new
          response.should have_selector( "form" , :method => "post", :action => "/sessions" ) do |form|
            form.should have_selector("input", :type => "text",      :name => "session[email]")
            form.should have_selector("input", :type => "password",  :name => "session[password]")
            form.should have_selector("input", :type => "submit")
          end
      end
    
  end
  
  describe "GET 'token'" do

     it "should be successful" do
       get :token
       response.should be_success
     end


     it "should have the right title" do
       get :token
       response.should have_selector("title", :content => "Sign in with token")
     end


       it "should not have a link for incorrect token page" do
           get :token
           response.should_not have_selector("a", :href => password_sessions_path ,  :content => "Incorrect toke get a new one !")
       end
       
       it "should have token form " do
            get :token
            response.should have_selector( "form" , :method => "post", :action => "/sessions/create_with_token" ) do |form|
              form.should have_selector("input", :type => "text",      :name => "session[email]")
              form.should have_selector("input", :type => "password",  :name => "session[token]")
              form.should have_selector("input", :type => "submit")
            end
        end

  end
  
  describe "POST 'create'" do

      describe "invalid signin" do

        before(:each) do
          @attr = { :email => "email@example.com", :password => "invalid" }
        end

        it "should re-render the new page" do
          post :create, :session => @attr
          response.should render_template('new')
        end

        it "should have the right title" do
          post :create, :session => @attr
          response.should have_selector("title", :content => "Sign in")
        end
        
        it "should have a link for forgotten password page" do
          post :create, :session => @attr
          response.should have_selector("a", :href => password_sessions_path,  :content => "Forgot your password ?")
        end
        

        it "should have a flash.now message" do
          post :create, :session => @attr
          flash.now[:error].should =~ /invalid/i
        end
      end
  
      describe "valid sign in " do
        
        before(:each) do
          @user = Factory(:user)
          @activation_token = Factory(:activation_token, :user => @user, :token => Factory.next(:token))
          @attr = { :email =>  @user.email, :password => @user.password }
        end
        
         it "should not have a activation token" do
            post :create, :session => @attr
            @user.activation_token.should == nil 
          end
      end
 
  end
     
  describe "POST 'create_with_token'" do

      describe "invalid signin" do

        before(:each) do
          @attr = { :email => "email@example.com", :token => "invalid" }
        end

        it "should re-render the token page" do
          post :create_with_token, :session => @attr
          response.should render_template('token')
        end

        it "should have the right title" do
          post :create_with_token, :session => @attr
          response.should have_selector("title", :content => "Sign in")
        end
        
        it "should have a link for forgotten password page" do
          post :create_with_token, :session => @attr
          response.should have_selector("a", :href => password_sessions_path ,  :content => "Incorrect token ?  Get a new one !")
        end
        

        it "should have a flash.now message" do
          post :create_with_token, :session => @attr
          flash.now[:error].should =~ /invalid/i
        end
      end
    
      describe "valid signin" do
        before(:each) do
           @user = Factory(:user)
           @activation_token = Factory(:activation_token, :user => @user, :token => Factory.next(:token))
           @attr = { :email => @user.email, :token => @activation_token.token }
        end
        
        it "should redirect_to edit_user_path(@user)" do
          post :create_with_token, :session => @attr
          response.should redirect_to edit_user_path(@user)
        end
        
        it "should destroy the users token" do
          post :create_with_token, :session => @attr
          @user.activation_token.should == nil 
        end
        
      end
 
  end
  
  describe "with valid email and password" do

          before(:each) do
            @user = Factory(:user)
            @attr = { :email => @user.email, :password => @user.password }
          end

          it "should sign the user in" do
            post :create, :session => @attr
            controller.current_user.should == @user
            controller.should be_signed_in
          end

          it "should redirect to the user show page" do
            post :create, :session => @attr
            response.should redirect_to(user_path(@user))
          end
  end

  describe "with valid email and token" do

          before(:each) do
            @user = Factory(:user)
            @activation_token = Factory(:activation_token, :user => @user, :token => Factory.next(:token))
            @attr = { :email => @user.email, :token => @activation_token.token }
          end

          it "should sign the user in" do
            post :create_with_token, :session => @attr
            controller.current_user.should == @user
            controller.should be_signed_in
          end

          it "should redirect to the user show page" do
            post :create_with_token, :session => @attr
            response.should redirect_to(edit_user_path(@user))
          end
  end
    
  describe "DELETE 'destroy'" do

        it "should sign a user out" do
          test_sign_in(Factory(:user))
          delete :destroy
          controller.should_not be_signed_in
          response.should redirect_to(root_path)
        end
        
  end
    
  describe "GET 'password' for forgotten password page" do
     it "should be successful" do
        get :password
        response.should be_success
      end
      
      it "should have the right title" do
        get :password
        response.should have_selector("title", :content => "Forgotten password")
      end
      
      it "should have password form " do
           get :password
           response.should have_selector( "form" , :method => "post", :action => "/sessions/send_password_request" ) do |form|
             form.should have_selector("input", :type => "text",     :name => "session[email]")
             form.should have_selector("input", :type => "submit")
           end
       end  
      
  end

  describe "POST 'send_password_request'" do
   
    before(:each) do
      @user = Factory(:user)
      @non_existing_email = "invalid@nomail.org"
    end
        
         it "should render the password page if email does not exists" do
           post :send_password_request,  :session => {:email => @non_existing_email}
           flash.now[:error].should =~ /This email does not exist in our database/i
           response.should render_template('password')
         end
           
             
          it "should render the token page if email exists" do
            post :send_password_request, :session => {:email => @user.email}
            flash.now[:success].should =~ /A temporary activation token has been sent to #{@user.email}/i
            response.should render_template('token')
          end
          
          it "should send an email and create a user activation token" do
            lambda do
              post :send_password_request, :session => {:email => @user.email}
            end.should change(ActivationToken,:count).by(1)
          end
                 
   
  end

end
