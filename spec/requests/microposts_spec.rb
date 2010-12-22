require 'spec_helper'

describe "Microposts" do
  
  before(:each) do
     @user = Factory(:user)
     visit signin_path(@user)
     fill_in :email,    :with => @user.email
     fill_in :password, :with => @user.password
     click_button
  end
  
  
  describe "creation" do
    
    describe "failure" do
      it "should not make a new micropost" do
        lambda do
          visit root_path
          fill_in :micropost_content , :with => ""
          click_button
          response.should render_template('pages/home')
          response.should have_selector("div#error_explanation")
        end.should_not change(Micropost, :count)
      end
    end
    
    describe "success" do
      
     it "should make a new micropost" do
          content = "Lorem ipsum dolor sit amet"
          lambda do
            visit root_path
            fill_in :micropost_content , :with => content
            click_button
            response.should have_selector("span.content", :content => content)
          end.should change(Micropost, :count).by(1)
      end 
      
    end
    
    describe "@replies" do
      
      before(:each) do
        @content = "   @#{@user.username} micropost sent to #{@user.name}"
         click_link "Sign out"
         @another_user = Factory(:user,:username => Factory.next(:username), :email => Factory.next(:email))
         visit signin_path(@another_user)
         fill_in :email,    :with => @another_user.email
         fill_in :password, :with => @another_user.password
         click_button
      end
      
       it "should make a new micropost for another_user " do
             
             lambda do
               visit root_path
               fill_in :micropost_content , :with => @content
               click_button
               response.should have_selector("span.content", :content => @content)
             end.should change(Micropost, :count).by(1)
             
         end
         
         it "should have another_users micropost in user's home page" do
           
           visit root_path
           fill_in :micropost_content , :with => @content
           click_button
           
           click_link "Sign out"
           
            visit signin_path(@user)
            fill_in :email,    :with => @user.email
            fill_in :password, :with => @user.password
            click_button
            visit root_path
            response.should have_selector("span.content", :content => @content)
            
         end
    end
  
  
  end
  
end
