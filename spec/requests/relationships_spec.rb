require 'spec_helper'

describe "Relationships" do
  
  before(:each) do
     @user = Factory(:user)
     @other_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
     visit signin_path(@user)
     fill_in :email,    :with => @user.email
     fill_in :password, :with => @user.password
     click_button
  end
  
  it "should follow an unfollowed user by clicking the follow button" do
    lambda do
      visit  user_path(@other_user)
      click_button 'relationship_submit'
      response.should render_template('users/show')
     end.should change(Relationship, :count).by(1)
     @user.following?(@other_user).should be_true
  end
  
  it "should unfollow user by clicking the unfollow button" do
      visit  user_path(@other_user)
      click_button 'relationship_submit'  # should follow user
      @user.following?(@other_user).should be_true
      click_button 'relationship_submit'  # should unfollow user
      @user.following?(@other_user).should be_false
  end
  
end