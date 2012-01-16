require 'spec_helper'

describe "LayoutLinks" do
  

  it "should have a Home page at '/'" do
    visit root_path
    page.should have_selector('title', :text => "Home")
  end

  it "should have a Contact page at '/contact'" do
    visit contact_path
    page.should have_selector('title', :text => "Contact")
  end

  it "should have an About page at '/about'" do
    visit about_path
    page.should have_selector('title', :text => "About")
  end
  
   it "should have a Help page at '/help'" do
    visit help_path
    page.should have_selector('title', :text => "Help")
  end
  
  it "should have a signup page at '/signup'" do
      visit signup_path
      page.should have_selector('title', :text => "Sign up")
    end
    
    it "should have a signin page at '/signin'" do
        visit signin_path
        page.should have_selector('title', :text => 'Sign in')
      end
    
    it "should have the right links on the layout" do
        visit root_path
        click_link "About"
        page.should have_selector('title', :text => "About")
        click_link "Help"
        page.should have_selector('title', :text => "Help")
        click_link "Contact"
        page.should have_selector('title', :text => "Contact")
        click_link "Home"
        page.should have_selector('title', :text => "Home")
        click_link "Sign up now!"
        page.should have_selector('title', :text => "Sign up")
      end
      
      describe "when not signed in" do
          it "should have a signin link" do
            visit root_path
            page.should have_link("Sign in", :href => signin_path)
          end
        end
        
        describe "when signed in" do

            before(:each) do
              @user = Factory(:user)
              visit signin_path
              fill_in "Email",    :with => @user.email
              fill_in "Password", :with => @user.password
              click_button "Sign in"
            end

            it "should have a signout link" do
              visit root_path
              page.should have_link("Sign out", :href => signout_path)
            end

            it "should have a profile link" do
                  visit root_path
                  page.should have_link("Profile", :href => user_path(@user))
            end
                
                
            it "should have a settings link'" do
                visit root_path
                page.should have_link("Settings",:href    => edit_user_path(@user))
            end
            
               it "should have a users link'" do
                    visit root_path
                    page.should have_link("Users",:href    => users_path)
                end
          end
        

  
end

describe "LayoutLinks for mobile device" do
  
  before(:each) do
    visit root_path
    click_link "Mobile Site"
  end
  
  
   it "should be a mobile_device" do
      visit '/'
      #controller.should be_mobile_device can't use this with capybara
      page.should have_link('Full Site')
    end
    

  
end
