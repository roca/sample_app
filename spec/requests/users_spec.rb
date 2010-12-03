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
             response.should have_selector("div.flash.success", :content => "Welcome")
             response.should render_template('users/show')
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
