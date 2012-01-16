require 'spec_helper'

describe "Users" do
  
  describe "signup" do
    
    describe "failure" do

      it "should not make a new user" do
        lambda do
            visit signup_path
            fill_in "Name",         :with => ""
            fill_in "Username",     :with => ""
            fill_in "Email",        :with => ""
            fill_in "Password",     :with => ""
            fill_in "Confirmation", :with => ""
            click_button 'Sign up'
            current_path.should eq(users_path)
            page.should have_selector("div#error_explanation")
        end.should_not change(User,:count)
       end

       it "should make a new user" do
         lambda do
             visit signup_path
             fill_in "Name",         :with => "RomelCampbell"
             fill_in "Username",     :with => "desertfox"
             fill_in "Email",        :with => "RomelCampbell@gmail.com"
             fill_in "Password",     :with => "foobar"
             fill_in "Confirmation", :with => "foobar"
             click_button "Sign up"
             page.should have_selector("div.flash.success", :text => "A temporary activation token has been sent to")
             current_path.should eq(users_path)
         end.should change(User,:count).by(1)
        end
    end
    
  end
  
  describe "sign in/out" do

  describe "failure" do
    it "should not sign a user in" do
      visit signin_path
      fill_in "Email",    :with => ""
      fill_in "Password", :with => ""
      click_button "Sign in"
      page.should have_selector("div.flash.error", :text => "Invalid")
      current_path.should eq(sessions_path)
    end
  end

  describe "success" do
    it "should sign a user in and out" do
      user = Factory(:user)
      visit signin_path
      fill_in "Email",    :with => user.email
      fill_in "Password", :with => user.password
      click_button "Sign in"
      # controller.should be_signed_in Capybara can't do this
      click_link "Sign out"
      current_path.should eq(root_path)
    end
    
     it "should also sign a user in and out with username" do
        user = Factory(:user)
        visit signin_path
        fill_in "Email",    :with => user.username
        fill_in "Password", :with => user.password
        click_button "Sign in"
        # controller.should be_signed_in Capybara can't do this
        click_link "Sign out"
        current_path.should eq(root_path)
      end
  end
  end
  
 describe "sign in with token" do
    
    describe "failure" do
      it "should not sign a user if email of token is incorrect" do
        visit token_sessions_path
        fill_in "Email",    :with => ""
        fill_in "Token",    :with => ""
        click_button "Sign in"
        page.should have_selector("div.flash.error", :content => "Invalid")
        current_path.should eq(create_with_token_sessions_path)
      end
    end
 
    describe "success" do
      it "should sign a user in" do
        user = Factory(:user)
        activation_token = Factory(:activation_token, :user => user, :token => Factory.next(:token))
      
        visit token_sessions_path
        fill_in "Email",    :with => user.email
        fill_in "Token",    :with => user.activation_token.token
        click_button "Sign in"
        # controller.should be_signed_in Capybara can't do this
        current_path.should eq(edit_user_path(user))
      end
    end
 end
 
 describe "search" do
   
  
   
   it "should allow signed in user to search for another user" do
      user = Factory(:user)
      another_user = Factory(:user,:name => "NotNameofFirstUser", :username => Factory.next(:username), :email => Factory.next(:email))
      visit signin_path
      fill_in "Email",    :with => user.email
      fill_in "Password", :with => user.password
      click_button "Sign in"
      # controller.should be_signed_in Capybara can't do this
      visit users_path
      fill_in "search", :with => another_user.email
      click_button 'search_submit'
      current_path.should eq(users_path)
      page.should     have_selector("li", :text => another_user.name)
      page.should_not have_selector("li", :text => user.name)
   end
   
   it "should not allow signed in user to search for another user with characters \' or \" " do
      user = Factory(:user)
      another_user = Factory(:user,:name => "NotNameofFirstUser", :username => Factory.next(:username), :email => Factory.next(:email))
      visit signin_path
      fill_in "Email",    :with => user.email
      fill_in "Password", :with => user.password
      click_button "Sign in"
      # controller.should be_signed_in Capybara can't do this
      visit users_path
      fill_in "search", :with => "\'#{another_user.email}\'"
      click_button 'search_submit'
      page.should         have_selector("div.flash.error", :text => "Invalid")
      page.should         have_content("Invalid")
      current_path.should eq(users_path)
      page.should     have_selector("li", :text => another_user.name)
      page.should     have_selector("li", :text => user.name)
   end
   
    it "should allow signed in user to search followed users feeds" do
       user = Factory(:user)
       another_user = Factory(:user,:name => "NotNameofFirstUser", :username => Factory.next(:username),:email => Factory.next(:email))
       mp1 = Factory(:micropost, :user => another_user , :content => "Foo Bar")
       mp2 = Factory(:micropost, :user => another_user , :content => "Baz quux")
       user.follow!(another_user)
       visit signin_path
       fill_in "Email",    :with => user.email
       fill_in "Password", :with => user.password
       click_button "Sign in"
       # controller.should be_signed_in Capybara can't do this
       visit root_path
       fill_in "search", :with => mp1.content
       click_button 'search_submit'
       current_path.should eq(root_path)
       page.should         have_selector("span.content", :text => mp1.content)
       page.should_not     have_selector("span.content", :text => mp2.content)
    end
    
    it "should allow signed in user search profile microposts" do
       user = Factory(:user)
       mp1 = Factory(:micropost, :user => user , :content => "Foo Bar")
       mp2 = Factory(:micropost, :user => user , :content => "Baz quux")

       visit signin_path
       fill_in "Email",    :with => user.email
       fill_in "Password", :with => user.password
       click_button "Sign in"
       # controller.should be_signed_in Capybara can't do this
       visit  user_path(user)
       fill_in "search", :with => mp1.content
       click_button 'search_submit'
       current_path.should eq(user_path(user))
       page.should             have_selector("span.content", :text => mp1.content)
       page.should_not         have_selector("span.content", :text => mp2.content)
    end
    
 end
   
 describe "password request" do
    
           it "should redirect to token_sessions_path if email exists" do
              user = Factory(:user)
              visit password_sessions_path
              fill_in :email,    :with => user.email
              click_button 'Send instructions'
              current_path.should eq(send_password_request_sessions_path)
            end
        
 end
  
  describe "Following users" do
    
    before(:each) do
      @user = Factory(:user)
      visit signin_path
      fill_in "Email",    :with => @user.email
      fill_in "Password", :with => @user.password
      click_button "Sign in"
      
      @other_user = Factory(:user, :username => Factory.next(:username),:email => Factory.next(:email))
      @user.follow!(@other_user)
    end
    
    it "should show user following" do
        visit following_user_path(@user)
        page.should have_link(@other_user.name, :href    => user_path(@other_user))
     end


     it "should show user following" do
       visit followers_user_path(@other_user)
       page.should have_link(@user.name, :href    => user_path(@user))
     end

  end
  
  
end
