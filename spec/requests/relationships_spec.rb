require 'spec_helper'

describe "Relationships" do
  
  before(:each) do
     @user = Factory(:user)
     @other_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
     visit signin_path(@user)
     fill_in "Email",    :with => @user.email
     fill_in "Password", :with => @user.password
     click_button "Sign in"
  end
  
  it "should follow an unfollowed user by clicking the follow button" do
    lambda do
      visit  user_path(@other_user)
      click_button 'Follow'
      current_path.should eq(user_path(@other_user))
     end.should change(Relationship, :count).by(1)
     @user.following?(@other_user).should be_true
  end
  
  it "should unfollow user by clicking the unfollow button" do
      visit  user_path(@other_user)
      click_button 'Follow'  # should follow user
      @user.following?(@other_user).should be_true
      click_button 'Unfollow'  # should unfollow user
      @user.following?(@other_user).should be_false
  end
  
end