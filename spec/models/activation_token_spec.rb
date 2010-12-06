require 'spec_helper'

describe ActivationToken do
  
  before(:each) do
    @user = Factory(:user)
    @attr = { :token => "loremipsum"}
  end
  
     it "should create a new instance with valid attributes" do
       @user.create_activation_token(@attr)
     end
     
     describe "user associations" do
       
       before(:each) do
         @token = @user.create_activation_token(@attr)
       end
       
       it "should have a user attribute" do
         @token.should respond_to(:user)
       end
       
       it "should have the right associated user" do
         @token.user_id.should == @user.id
         @token.user.should == @user
       end
     end
     
     describe "validations" do
       
       it "should have a user id" do
         ActivationToken.new(@attr).should_not be_valid
       end
       
       it "should require nonblank content" do
          @user.build_activation_token(:token => "    ").should_not be_valid
       end
  
            it "should only have one activation_token per user" do
              lambda do
                 @user.create_activation_token(:token => "test").should
                @user.create_activation_token(:token => "test").should
                @user.create_activation_token(:token => "test").should
              end.should change(ActivationToken,:count).by(1)
            end
       
     end
 end
