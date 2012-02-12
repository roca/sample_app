require 'spec_helper'


describe Micropost do
  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "lorem ipsum" }
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
     
     describe "in_reply_to methods"  do
      
      before(:each) do
         @another_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
         @attr2 = { :content => "@#{@user.username} micropost directed at #{@user.name}" ,:in_reply_to => @user.id}
         @microposts = @another_user.microposts.create(@attr2)
       end

       it "should have a in_reply_to attribute" do
          @microposts.should respond_to(:in_reply_to)
        end
        it "should have a recipient attribute" do
           @microposts.should respond_to(:recipient)
         end
         
         it "should belong to a recipient" do
            @microposts.in_reply_to.should == @user.id
            @microposts.recipient.should == @user 
            @user.microposts_from_others[0].should == @microposts
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
     
     describe "from_users_followed_by" do
       
       before(:each) do
         @other_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
         @third_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
         
         @user_post  = @user.microposts.create!(:content => "foo")
         @other_post = @other_user.microposts.create!(:content => "bar")
         @third_post = @third_user.microposts.create!(:content => "baz", :in_reply_to => @user.id)
         
         @user.follow!(@other_user)
        end
        
        it "should have a from_users_followed_by method" do
          Micropost.should respond_to(:from_users_followed_by)
        end
        
        it "should include the followed user's micropost" do
        
           Micropost.from_users_followed_by(@user).should include(@other_post)
        
        end
        
        it "should include the user's own microposts" do
      
          Micropost.from_users_followed_by(@user).should include(@user_post)
       
       end
        
        it "should not include an unfollowed user's microposts" do
      
          Micropost.from_users_followed_by(@user).should_not include(@third_post)
       
       end
       
       
       it "should include an unfollowed user's microposts if micropost was sent to user" do
      
          Micropost.from_users_sent_to(@user).should include(@third_post)
       
       end
     end

     describe "search method" do

       before(:each) do
          @other_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
          @third_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))

          @user_post  = @user.microposts.create!(:content => "foo")
          @other_post = @other_user.microposts.create!(:content => "bar")
          @third_post = @third_user.microposts.create!(:content => "baz")

          @user.follow!(@other_user)
         end

             it "should have an search method" do
              Micropost.should respond_to(:search)
             end

             it "should return array from search" do
               Micropost.search(@user_post.content).should == [@user_post]
             end

             it "should serach content columns and except string fragments" do
                Micropost.search(@user_post.content[1,2]).should  include(@user_post)
             end

             it "should serach name and email columns and except string fragments ignoring case" do
                  Micropost.search(@user_post.content[1,2].upcase).should  include(@user_post)
             end

             it "should allow for mutiple key words to narrow down search" do
                 fragment_1 = @user_post.content
                 fragment_2 = @third_post.content
                 Micropost.search("#{fragment_1}").should include(@user_post)
                 Micropost.search("#{fragment_2}").should include(@third_post)
                 Micropost.search("#{fragment_1} #{fragment_2}").count == 0
             end


             it "should return all records from blank search" do
               Micropost.search(" ").should == Micropost.all
             end

             it "should not search unfollowed user's microposts" do
               Micropost.from_users_followed_by(@user).search(@other_post.content).should_not include(@third_post)
               Micropost.from_users_followed_by(@user).search(" ").should_not include(@third_post)
             end
 
             it "should search followed user's microposts" do
                Micropost.from_users_followed_by(@user).search(@other_post.content).should include(@other_post)
             end

             it "should not search all microposts" do
               Micropost.from_users_followed_by(@user).search(" ").should_not == Micropost.all
             end

     end

     describe "micropost audit" do

         before(:each) do
           @one_months_ago   = (Time.now - 1.months)
           @two_months_ago   = (Time.now - 2.months)
           @three_months_ago = (Time.now - 3.months)
           @four_months_ago  = (Time.now - 4.months)
           @another_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
           
           
           
           50.times do
             @user.microposts.create!({:content => Faker::Lorem.sentence(5)})
             microposts = Micropost.where(["user_id = ? and created_at > ? ",@user,(Time.now - 1.day)])
             microposts.each do |micropost|
                micropost.created_at = @two_months_ago
                micropost.save
              end
            end
             50.times do
               @user.microposts.create!({:content => Faker::Lorem.sentence(5)})
                microposts = Micropost.where(["user_id = ? and created_at > ? ",@user,(Time.now - 1.day)])
                microposts.each do |micropost|
                  micropost.created_at = @three_months_ago
                  micropost.save
                end
              end
                         
              50.times do
                @user.microposts.create!({:content => Faker::Lorem.sentence(5)})
                 microposts = Micropost.where(["user_id = ? and created_at > ? ",@user,(Time.now - 1.day)])
                 microposts.each do |micropost|
                   micropost.created_at = @four_months_ago
                   micropost.save
                 end
               end
              
              
              50.times do
                 @user.microposts.create!({:content => Faker::Lorem.sentence(5)})
                end
           
              200.times do
                @another_user.microposts.create!({:content => Faker::Lorem.sentence(5)})
              end
                
                
           end
                  
           it "should have 100 micropost since two months ago" do
             microposts = Micropost.where(["user_id = ? and created_at between ? and ?",@user,@two_months_ago, Time.now])
             microposts.length.should == 100 
           end
           
           it "should have 100 micropost between three and two months ago " do
             microposts = Micropost.where(["user_id = ? and created_at between ? and ?",@user,@three_months_ago, @two_months_ago])
             microposts.length.should == 100 
           end
           
           
         it "should have 100 micropost between four and three months ago " do
           
           microposts = Micropost.where(["user_id = ? and created_at between ? and ?",@user,@four_months_ago, @three_months_ago])
           microposts.length.should == 100
           
         end
         
         it "should have 50 micropost older than four months ago " do
           
           microposts = Micropost.where(["user_id = ? and created_at <= ?",@user,@four_months_ago])
           microposts.length.should == 50
           
         end
         
         it "should have 25 allowed micropost since two months ago" do
           allowed_microposts = Micropost.where(["user_id = ? and created_at between ? and ?",@user,@one_months_ago, Time.now]).order("id desc").limit(25)
           
           tobe_deleted =  Micropost.where(["user_id = ? ",@user]) - allowed_microposts
           tobe_deleted.length.should == 175
           
           Micropost.destroy tobe_deleted.collect {|r| r.id}
           
           Micropost.where(["user_id = ? ",@user]).order("id desc").first.should == allowed_microposts.first
           Micropost.where(["user_id = ? ",@user]).order("id desc").last.should == allowed_microposts.last
           Micropost.where(["user_id = ? ",@user]).order("id desc").length.should == allowed_microposts.length
           
           
         end
         
     end

end
