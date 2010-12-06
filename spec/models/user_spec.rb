require 'spec_helper'

describe User do
  
  before(:each) do
   @attr = { :name                   => "Excample user", 
             :email                  => "user@example.com",
             :password               => "foobar", 
             :password_confirmation  => "foobar"
          }
  end
  
  it "should create a new instance given a valid attribute" do
      User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end
  
  it "should require a name" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      addresses.each do |address|
        valid_email_user = User.new(@attr.merge(:email => address))
        valid_email_user.should be_valid
      end
  end

  it "should reject invalid email addresses" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      addresses.each do |address|
        invalid_email_user = User.new(@attr.merge(:email => address))
        invalid_email_user.should_not be_valid
      end
  end
  
  it "should reject invalid email addresses" do 
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.] 
      addresses.each do |address|
        invalid_email_user = User.new(@attr.merge(:email => address))
        invalid_email_user.should_not be_valid 
      end
  end
     
  it "should reject user with duplicate email" do
       User.create!(@attr)
       user_with_duplicate_email = User.new(@attr)
       user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses indentical up to case" do
      upcased_email = @attr[:email].upcase
      User.create!(@attr.merge(:email => upcased_email))
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
  end
    
    describe "passswords" do
      before(:each) do
        @user = User.new(@attr)
      end
      it "should have a password attribute" do
        @user.should respond_to(:password)
      end
      
      it "should have a password confirmation attribute" do
        @user.should respond_to(:password_confirmation)
      end
      
    end
    
    describe "password validations" do
      it "should require a password" do
       User.new(@attr.merge(:password => "", :password_confirmation => "")).
       should_not be_valid
      end
      
      it "should require a matching password confirmation" do
       User.new(@attr.merge(:password_confirmation => "invalid")).
       should_not be_valid
      end
      
      it "should reject short passwords" do
        short = "a" * 5
        hash = @attr.merge(:password => short, :password_confirmation => short)
        User.new(hash).should_not be_valid
      end
      
      it "should reject long passwords" do
        long = "a" * 41
        hash = @attr.merge(:password => long, :password_confirmation => long)
        User.new(hash).should_not be_valid
      end
    end
    
    describe "password encryption" do
      
      before(:each) do
        @user = User.create!(@attr)
      end
      
      it "should have an encrypted password attribute" do
        @user.should respond_to(:encrypted_password)
      end
      
      it "should set the encrypted password attribute" do
        @user.encrypted_password.should_not be_blank
        
      end
      
      it "should have an salt attribute" do
        @user.should respond_to(:salt)
      end
      
      describe "has_password? method" do
        
        it "should have an has_password? method" do
          @user.should respond_to(:has_password?)
        end

        it "should be true if the passwords match" do
              @user.has_password?(@attr[:password]).should be_true
        end    

        it "should be false if the passwords don't match" do
              @user.has_password?("invalid").should be_false
        end 
      end
      
      describe "authenticate method" do
        
        it "should have an authenticate method" do
         User.should respond_to(:authenticate)
        end
        
        it "should return nil on email/password mismatch" do
          User.authenticate(@attr[:email],"wrong_password").should be_nil
        end
        
         it "should return nil for an email address with no user" do
            User.authenticate("bar@foo.com",@attr[:email]).should be_nil
          end
          
          it "should return the user on email/password match" do
            User.authenticate(@attr[:email],@attr[:password]).should == @user
          end
      end
      
    end
    
    describe "admin attribute" do
      
      before(:each) do
        @user = User.create!(@attr)
      end
      
       it "should have a admin attribute" do
          @user.should respond_to(:admin)
       end
       
       it "should not be a admin by defalt" do
           @user.should_not be_admin
       end
       
       it "should be convertible to an admin" do
            @user.toggle!(:admin)
            @user.should be_admin
       end 
       
    end
     
    describe "microposts associations" do

        before(:each) do
          @user = User.create(@attr)
          @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
          @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
        end

        it "should have a microposts attribute" do
          @user.should respond_to(:microposts)
        end

        it "should have the right microposts in the right order" do
          @user.microposts.should == [@mp2,@mp1]
        end
        
        it "should destroy associated microposts" do
          @user.destroy
          [@mp2,@mp1].each do |micropost|
           lambda do
            Micropost.find(micropost.id)
           end.should raise_error(ActiveRecord::RecordNotFound)
          end
    end
        
    describe "status feed" do
          
            it "should have a feed" do
              @user.should respond_to(:feed)
            end
            
            it "should include the users microposts" do
              @user.feed.should include(@mp1)
              @user.feed.should include(@mp2)
            end
            
            it "should not include a diiferent user's microposts" do
              @mp3 = Factory(:micropost, 
                             :user => Factory(:user, 
                                              :email => Factory.next(:email)))
              @user.feed.should_not include(@mp3)
            end
            
            it "should include the micrposts of follwed users" do
              followed = Factory(:user, :email => Factory.next(:email))
              mp3 = Factory(:micropost, :user => followed)
              @user.follow!(followed)
              @user.feed.should include(mp3)
            end
    end
        
    describe "relationships" do
      
      before(:each) do
        @user = Factory(:user)
        @followed = Factory(:user, :email => Factory.next(:email))
      end
      
      it "should have a relationships method" do
        @user.should respond_to(:relationships)
      end
      
      it "should have a following method" do
        @user.should respond_to(:following)
      end
      
      it "should follow another user" do
        @user.follow!(@followed)
        @user.should be_following(@followed)
      end
       
       it "should include the followed user in the following array" do
          @user.follow!(@followed)
          @user.following.should include(@followed)
       end
       
        it "should have a follow! method" do
           @user.should respond_to(:follow!)
        end
        
        it "should have a unfollow! method" do
           @user.should respond_to(:unfollow!)
        end
        
        it "should unfollow a user" do
          @user.follow!(@followed)
          @user.unfollow!(@followed)
          @user.should_not be_following(@followed)
          @user.following?(@followed).should be_false
        end
        
        it "should have a reverse_relationships method" do
          @user.should respond_to(:reverse_relationships)
        end
        
        it "should have a followers method" do
          @user.should respond_to(:followers)
        end
        
        it "should include the follower in the followers array" do
            @user.follow!(@followed)
            @followed.followers.should include(@user)
         end
    end

    describe "acivation token associations" do

        before(:each) do
          @user =  Factory(:user)
          @user_with_out_token = Factory(:user , :email => Factory.next(:email))
          @token = Factory(:activation_token, :user => @user, :token => Factory.next(:token))
        end

        it "should have a activation_token attribute" do
          @user.should respond_to(:activation_token)
        end
        
             
       it "should have the right activation_token in the right order" do
          @user.activation_token.should == @token
       end
       
       it "should have the right activation_token in the right order" do
          @user.activation_token.token.should == @token.token
       end
   
          
        it "should destroy associated activation_token" do
          @user.destroy
           lambda do
            ActivationToken.find(@token.id)
           end.should raise_error(ActiveRecord::RecordNotFound)
        end
        
        it "should have a is_active? method" do
          @user.should respond_to(:active?)
        end
        
        
        
           it "should have a activate method" do
             @user.should respond_to(:activate)
           end 
           
           it "should remove user's token when user is activated"  do
             @user.activate
             @user.activation_token.should == nil
             @user.active?.should be_true
           end
           
           it "should have a deactivate method"  do
             @user.should respond_to(:deactivate)            
            end
           
           it "should give user a token when user is deactivated" do
             @user_with_out_token.deactivate
             @user_with_out_token.activation_token.should_not == nil
             @user_with_out_token.active?.should be_false
           end
           
        
          it "should only have one activation token per user" do
            lambda do
              @user_with_out_token.deactivate
              @user_with_out_token.deactivate
              @user_with_out_token.deactivate
            end.should change(ActivationToken,:count).by(1)
           end
         
          
    end

end
      
     
end