require 'spec_helper'

describe "FriendlyForwardings" do
  
    it "should forward to the requested page after signin" do
      user = Factory(:user)
      visit edit_user_path(user)
      fill_in "Email",    :with => user.email
      fill_in "Password", :with => user.password
      click_button "Sign in"
      current_path.should eq(edit_user_path(user))
      visit signout_path
      visit signin_path
      fill_in "Email",    :with => user.email
      fill_in "Password", :with => user.password
      click_button "Sign in"
      current_path.should eq(root_path)
    end
  
end
