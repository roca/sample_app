require "spec_helper"

describe UserMailer do
  
  before(:each) do
    @user = Factory(:user)
    @email = UserMailer.send_password_request(@user)
  end
  
  
  it "should respond to send_password_request" do
    UserMailer.should respond_to(:send_password_request)
  end
  
  it " should send send_password_request" do
    @email.deliver
    ActionMailer::Base.deliveries.should_not be_empty
    @email.body.should =~ /#{@user.email}/i
    @email.body.should =~ /#{@user.activation_token.token}/i
  end
  
  it "should have a link for the edit_user_path " do
     @email.body.should =~ /sessions\/token/i
  end
  
end
