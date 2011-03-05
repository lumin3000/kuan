require 'spec_helper'

describe MessagesController do
 
  before :each do
    @user = Factory :user
    controller.sign_in @user
  end

  after :each do
    User.delete_all
    Blog.delete_all
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index' 
      response.should be_success
    end
  end
 

end
