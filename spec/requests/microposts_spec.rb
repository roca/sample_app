require 'spec_helper'

describe "Microposts" do
  
  before(:each) do
     @user = Factory(:user)
     visit signin_path(@user)
     fill_in "Email",    :with => @user.email
     fill_in "Password", :with => @user.password
     click_button "Sign in"
  end
  
  
  describe "creation" do
    
    describe "failure" do
      it "should not make a new micropost" do
        lambda do
          visit root_path
          fill_in "micropost_content" , :with => ""
          click_button "Submit"
           current_path.should eq(microposts_path)
          page.should have_selector("div#error_explanation")
        end.should_not change(Micropost, :count)
      end
    end
    
    describe "success" do
      
     it "should make a new micropost" do
          content = "Lorem ipsum dolor sit amet"
          lambda do
            visit root_path
            fill_in "micropost_content" , :with => content
            click_button  "Submit"
            page.should have_selector("span.content", :text => content)
          end.should change(Micropost, :count).by(1)
      end 
      
    end
    
     describe "@replies" do
      
      before(:each) do
        @content = "@#{@user.username} micropost sent to #{@user.name}"
         click_link "Sign out"
         @another_user = Factory(:user,:username => Factory.next(:username), :email => Factory.next(:email))
         visit signin_path(@another_user)
         fill_in "Email",    :with => @another_user.email
         fill_in "Password", :with => @another_user.password
         click_button "Sign in"
      end
      
       it "should make a new micropost for another_user " do
             
             lambda do
               visit root_path
               fill_in "micropost[content]" , :with => @content
               click_button  "Submit"
               
             end.should change(Micropost, :count).by(1)
             page.should have_selector("span.content", :text => @content)
             
         end
         
         it "should have another_users micropost in user's home page" do
           
           visit root_path
           fill_in "micropost_content" , :with => @content
           click_button "Submit"
           
           click_link "Sign out"
           
            visit signin_path(@user)
            fill_in "Email",    :with => @user.email
            fill_in "Password", :with => @user.password
            click_button "Sign in"
            visit root_path
            page.should have_selector("span.content", :text => @content)
            
         end
     end
  
  
  end
  
end
