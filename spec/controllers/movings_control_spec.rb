require 'spec_helper'

describe MovingsController do
 
  before :each do
    @user = Factory :user
    controller.sign_in @user
  end

  after :each do
    User.delete_all
    Blog.delete_all
    Moving.delete_all
  end

  describe "GET 'new'" do
    it "should be successful" do
      # get 'new'
      # response.should be_success
    end
  end

  describe "POST 'create'" do 

    before :each do
      @blog = Blog.create(:uri => "lintb_new", :title => "lintb_new")
      @user.follow! @blog, "founder" 
      @attr = {:from_uri => "deviantart13"}
    end

    it "should be successful" do
      # lambda do
      #   # post 'create', :moving => @attr
      #   # response.should render_template 'new'
      #   # flash.now[:success].should_not be_blank
      # end.should change(Moving, :count).by(1) 
    end

    it "should be fail" do
      # lambda do
      #   # post 'create', :moving => @attr.merge(:from_uri => " ")
      #   # response.should render_template 'new'
      # end.should_not change(Moving, :count).by(1) 
    end

  end

end
