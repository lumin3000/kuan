require 'spec_helper'

describe SessionsController do
  render_views

  before(:each) do
    @user = Factory(:user)
  end

  after(:each) do
    User.delete_all
  end 

  describe "POST 'create'" do
    describe "invalid signin" do
      before(:each) do
        @attr = { :email => "invalid@k.com", :password => "invalid"}
      end

      it "should render the new page" do
        post :create, :session => @attr
        response.should render_template 'new'
      end

      it "should have a flash.now message when email error" do
        post :create, :session => @attr.merge(:email => @user.email)
        flash.now[:email_error].should be_blank
        flash.now[:password_error].should_not be_blank
      end
    end

    describe "valid signin" do
      before(:each) do
        @attr = { :email => @user.email, :password => @user.password}
      end

      it "should redirect to home" do
        post :create, :session => @attr
        response.should redirect_to '/home'
      end

      it "should check the user sign in" do
        post :create, :session => @attr
        controller.current_user.should == @user
        controller.should be_signed_in
      end
    end
  end
end 
