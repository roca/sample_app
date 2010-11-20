require 'spec_helper'

describe Micropost do
  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "lorem ipsum", :users_id => 1 }
  end
  
     it "should create a new instance with valid attributes" do
       @user.microposts.create!(@attr)
     end
     
     describe "user associations" do
       
       before(:each) do
         @microposts = @user.microposts.create(@attr)
       end
       
       it "should have a user attribute" do
         @microposts.should respond_to(:user)
       end
       
       it "should have the right associated user" do
         @microposts.user_id.should == @user.id
         @microposts.user.should == @user
       end
     end
     
     describe "validations" do
       
       it "should have a user id" do
         Micropost.new(@attr).should_not be_valid
       end
       
       it "should require nonblank content" do
          @user.microposts.build(:content => "    ").should_not be_valid
       end
  
       it "should reject lon content" do
           @user.microposts.build(:content => "a" * 141).should_not be_valid
        end  
     end
end
