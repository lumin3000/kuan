require 'spec_helper'

describe BlogsController do
  render_views

  before :each do
    @user = Factory :user
    @blog = Factory :blog
  end

  after :each do
    User.delete_all
    Blog.delete_all
  end

  describe "access control" do
    it "should deny access to 'new'" do
      get :new
      response.should redirect_to signin_path
    end

    it "should deny access to 'create'" do
      post :create
      response.should redirect_to signin_path
    end

    it "should deny access to 'edit'" do
      get :edit, :id => @blog
      response.should redirect_to signin_path
    end

    it "should deny access to 'update'" do
      put :update, :id => @blog
      response.should redirect_to signin_path
    end

    it "should deny access for 'edit' when not founder" do
      controller.sign_in @user
      get :edit, :id => @blog
      response.should redirect_to home_path
    end

    it "should deny access for 'update' when not founder" do
      controller.sign_in @user
      put :update, :id => @blog
      response.should redirect_to home_path
    end

  end

  describe "GET 'new'" do
    it "should be successful" do
      controller.sign_in @user
      get :new
      response.should be_success
    end
  end

  describe "POST 'create'" do

    before :each do
      controller.sign_in @user
    end

    describe "failure" do
      before :each do
        @attr = {:title => "",
          :uri => ""}
      end

      it "should not create a blog" do
        lambda {post :create, :blog => @attr}.should_not change(Blog, :count)
      end

      it "should render the 'new' page" do
        post :create, :blog => @attr
        response.should render_template 'new'
      end
    end

    describe "success" do
      before :each do
        @attr = {:title => "example title",
          :uri => "example"}
      end

      it "should create a blog" do
        lambda do
          post :create, :blog => @attr
        end.should change(Blog, :count).by(1)
      end

      it "should redirece to home" do
        post :create, :blog => @attr
        response.should redirect_to home_path
      end

      it "should have a welcome message" do
        post :create, :blog => @attr
        flash[:success].should_not be_blank
      end

      it "should create user followings" do
        post :create, :blog => @attr
        @user.reload
        @user.blogs.first.uri.should == @attr[:uri]
        @user.blogs.first.title.should == @attr[:title]
      end
    end
  end

  describe "GET 'edit'" do
    before :each do
      controller.sign_in @user
      @user.follow! @blog, "founder"
    end

    it "should be successful" do
      get :edit, :id => @blog
      response.should render_template 'edit'
    end
  end

  describe "PUT 'update'" do

    before :each do
      controller.sign_in @user
      @user.follow! @blog, "founder"
    end

    describe "failure" do
      before :each do
        @attr = {:title => "",
          :uri => ""}
      end 

      it "should render the 'edit' page" do
        put :update, :id => @blog, :blog => @attr
        response.should render_template 'edit'
      end
    end

    describe "success" do
      before :each do
        @attr = {:title => "update title",
          :uri => "update"}
      end

      it "should change blog's attribute" do
        put :update, :id => @blog, :blog => @attr
        @blog.reload
        @blog.title.should == @attr[:title]
        @blog.uri.should == @attr[:uri]
      end

      it "should have a flash message" do
        put :update, :id => @blog, :blog => @attr
        flash[:success].should_not be_blank
      end

      it "should redirect to home" do
        put :update, :id => @blog, :blog => @attr
        response.should redirect_to home_path
      end
    end
  end

  describe "GET 'followers'" do
    it "should display followers" do
      controller.sign_in @user
      user1 = Factory :user, :email => Factory.next(:email)
      user2 = Factory :user, :email => Factory.next(:email)
      user1.follow! @blog
      user2.follow! @blog
      get :followers, :id => @blog
      response.should have_selector("div",
                                    :content => user1.name)
      response.should have_selector("div",
                                    :content => user2.name)
    end
  end

end
