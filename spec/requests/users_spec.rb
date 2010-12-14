require 'spec_helper'

describe "Users" do
  
  describe "signup" do
    
    describe "failure" do

      it "should not make a new user" do
        lambda do
            visit signup_path
            fill_in "Name",         :with => ""
            fill_in "Email",        :with => ""
            fill_in "Password",     :with => ""
            fill_in "Confirmation", :with => ""
            click_button
            response.should render_template('users/new')
            response.should have_selector("div#error_explanation")
        end.should_not change(User,:count)
       end

       it "should make a new user" do
         lambda do
             visit signup_path
             fill_in "Name",         :with => "RomelCampbell"
             fill_in "Email",        :with => "RomelCampbell@gmail.com"
             fill_in "Password",     :with => "foobar"
             fill_in "Confirmation", :with => "foobar"
             click_button
             response.should have_selector("div.flash.success", :content => "A temporary activation token has been sent to")
             response.should render_template('sessions/token')
         end.should change(User,:count).by(1)
        end
    end
    
  end
  
  describe "sign in/out" do

  describe "failure" do
    it "should not sign a user in" do
      visit signin_path
      fill_in :email,    :with => ""
      fill_in :password, :with => ""
      click_button
      response.should have_selector("div.flash.error", :content => "Invalid")
      response.should render_template('sessions/new')
    end
  end

  describe "success" do
    it "should sign a user in and out" do
      user = Factory(:user)
      visit signin_path
      fill_in :email,    :with => user.email
      fill_in :password, :with => user.password
      click_button
      controller.should be_signed_in
      click_link "Sign out"
      controller.should_not be_signed_in
    end
  end
  end
  
 describe "sign in with token" do
    
    describe "failure" do
      it "should not sign a user if email of token is incorrect" do
        visit token_sessions_path
        fill_in :email,    :with => ""
        fill_in :token,    :with => ""
        click_button
        response.should have_selector("div.flash.error", :content => "Invalid")
        response.should render_template('sessions/token')
      end
    end
 
    describe "success" do
      it "should sign a user in" do
        user = Factory(:user)
        activation_token = Factory(:activation_token, :user => user, :token => Factory.next(:token))
      
        visit token_sessions_path
        fill_in :email,    :with => user.email
        fill_in :token,    :with => user.activation_token.token
        click_button
        controller.should be_signed_in
        response.should render_template("users/edit")
      end
    end
 end
 
 describe "search" do
   it "should allow signed in user to search for another user" do
      user = Factory(:user)
      another_user = Factory(:user,:name => "NotNameofFirstUser", :email => Factory.next(:email))
      visit signin_path
      fill_in :email,    :with => user.email
      fill_in :password, :with => user.password
      click_button
      controller.should be_signed_in
      visit users_path
      fill_in :search, :with => another_user.email
      click_button
      response.should render_template('users/index')
      response.should     have_selector("li", :content => another_user.name)
      response.should_not have_selector("li", :content => user.name)
   end
   
   
    it "should allow signed in user to search followed users feeds" do
       user = Factory(:user)
       another_user = Factory(:user,:name => "NotNameofFirstUser", :email => Factory.next(:email))
       mp1 = Factory(:micropost, :user => another_user , :content => "Foo Bar")
       mp2 = Factory(:micropost, :user => another_user , :content => "Baz quux")
       user.follow!(another_user)
       visit signin_path
       fill_in :email,    :with => user.email
       fill_in :password, :with => user.password
       click_button
       controller.should be_signed_in
       visit root_path
       fill_in :search, :with => mp1.content
       click_button 'search_submit'
       response.should render_template('pages/home')
       response.should         have_selector("span.content", :content => mp1.content)
       response.should_not     have_selector("span.content", :content => mp2.content)
    end
    
    it "should allow signed in user search profile microposts" do
       user = Factory(:user)
       mp1 = Factory(:micropost, :user => user , :content => "Foo Bar")
       mp2 = Factory(:micropost, :user => user , :content => "Baz quux")

       visit signin_path
       fill_in :email,    :with => user.email
       fill_in :password, :with => user.password
       click_button
       controller.should be_signed_in
       
       visit  user_path(user)
       fill_in :search, :with => mp1.content
       click_button 'search_submit'
       response.should render_template('users/show')
       response.should         have_selector("span.content", :content => mp1.content)
       response.should_not     have_selector("span.content", :content => mp2.content)
    end
    
 end
   
 describe "password request" do
    
           it "should redirect to token_sessions_path if email exists" do
              user = Factory(:user)
              visit password_sessions_path
              fill_in :email,    :with => user.email
              click_button
              response.should render_template('sessions/token')
            end
        
 end
  
  
end
