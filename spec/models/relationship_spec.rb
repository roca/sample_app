require 'spec_helper'

describe Relationship do
  
  before(:each) do
    @follower = Factory(:user)
    @followed = Factory(:user,  :username => Factory.next(:username), :email => Factory.next(:email))
    
    @attr = { :followed_id => @followed.id }
  end
  
     it "should create a new instance with valid attributes" do
       lambda do
        @follower.relationships.create!(@attr)
       end.should change(Relationship,:count).by(1)
     end
     
        it "should create a new instance with valid attributes once" do
          @follower.relationships.create!(@attr)
          @follower.relationships.build(@attr).should_not be_valid
        end
     
     describe "follow methods" do
       
       before(:each) do
         @relationship = @follower.relationships.create!(@attr)
       end
       
       it "should have a follower attribute" do
         @relationship.should respond_to(:follower)
       end
       
       it "should have the right follower" do
         @relationship.follower.should == @follower
       end
       
       it "should have a followed attribute" do
          @relationship.should respond_to(:followed)
       end
       
       it "should have the right followed user" do
          @relationship.followed.should == @followed
       end
       
       it "should destroy relationship" do
          Relationship.find(@relationship).should_not be_nil
          @followed.destroy
          Relationship.find_by_id(@relationship).should be_nil
       end
       
       it "should destroy relationship" do
          Relationship.find(@relationship).should_not be_nil
          @follower.destroy
          Relationship.find_by_id(@relationship).should be_nil
       end
        
     end
       
       
     describe "validations" do
       
       it "should require a follower id" do
         Relationship.new(@attr).should_not be_valid
       end
       
       it "should require a followed id" do
          @follower.relationships.build.should_not be_valid
        end
        
     end
end
