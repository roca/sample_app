require 'spec_helper'

describe MicropostsController do
  render_views
  
 describe "access to create" do
  
    it "should deny access to 'create'" do   
        post :create
        response.should redirect_to(signin_path) 
    end
    
    it "should deny access to 'destroy'" do   
         delete :destroy, :id => 1
         response.should redirect_to(signin_path) 
    end
 
 end
  
 describe "POST 'create'" do
    
    before(:each) do
      @user = test_sign_in(Factory(:user))
      @another_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
      @third_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
      @user.follow!(@third_user)
    end
    
    describe "failure" do
      
          before(:each) do
           @attr = {:content => ""}
           @attr2 = {:content => "@nonExistingUser micropost sent to #{@another_user.name}"}
          end
          
          it "should not create a micropost" do
            lambda do
             post :create , :micropost => @attr
            end.should_not change(Micropost,:count)
          end
          
          it "should re-render the home page" do
            post :create , :micropost => @attr
            response.should render_template("pages/home")
          end
          
          it "should flash error for @nonExistingUser but still redirect to the root path" do
             post :create , :micropost => @attr2
             response.should redirect_to root_path
             flash[:success].should =~ /micropost created/i
             flash[:error].should =~ /User with username:nonExistingUser does not exist!/i
          end
    end
      
    describe "success" do
      
      
      before(:each) do
        @attr = {:content => "This is a valid micropost"}
        @attr2 = {:content => "@#{@another_user.username} micropost sent to #{@another_user.name}"}
        @attr3 = {:content => "   @#{@another_user.username} micropost sent to #{@another_user.name}"}
       end
       
             it "should create a micropost" do
               lambda do
                post :create , :micropost => @attr
               end.should change(Micropost,:count).by(1)
             end
             
             it "should share a micropost with another_user" do
                 lambda do
                 post :create , :micropost => @attr
                 post :create , :micropost => @attr2
                 end.should change(@another_user.microposts_from_others,:count).by(1)
                 Micropost.from_users_sent_to(@another_user)[0].content.should == @attr2[:content] 
                 
                 @another_user.feed.should include(@another_user.microposts_from_others[0])
                 @user.feed.should include(@another_user.microposts_from_others[0])
                 @third_user.feed.should_not include(@another_user.microposts_from_others[0])
                 
             end
              
              it "should not matter if spaces preceed @reply text" do
                   lambda do
                   post :create , :micropost => @attr
                   post :create , :micropost => @attr3
                   end.should change(@another_user.microposts_from_others,:count).by(1)
                   Micropost.from_users_sent_to(@another_user)[0].content.should == @attr3[:content] 

                   @another_user.feed.should include(@another_user.microposts_from_others[0])
                   @user.feed.should include(@another_user.microposts_from_others[0])
                   @third_user.feed.should_not include(@another_user.microposts_from_others[0])

               end
              
       
             it "should redirect to the root path" do
               post :create , :micropost => @attr
               response.should redirect_to root_path
             end
             
             it "should have a flash success message" do
               post :create , :micropost => @attr
               flash[:success].should =~ /micropost created/i
             end
    end
 end

 describe "DELETE 'destroy'" do

   describe "for an unauthorized user" do
     
       before(:each) do
         @user = Factory(:user)
         wrong_user = Factory(:user, :username => Factory.next(:username),:email => Factory.next(:email))
         @micropost = Factory(:micropost, :user => @user)
         test_sign_in(wrong_user)
       end
       
      it "should deny access" do
        delete :destroy , :id => @micropost
        response.should redirect_to root_path         
      end
     
   end
   
   describe "for an authorized user" do
     
     before(:each) do
         @user = test_sign_in(Factory(:user))
         @micropost = Factory(:micropost, :user => @user)
     end
     
     it "should destroy the micropost" do
       lambda do
       delete :destroy , :id => @micropost
       flash[:success] =~ /deleted/i
       response.should redirect_to root_path
       end.should change(Micropost,:count).by(-1)
     end
     
   end
    
 end
end