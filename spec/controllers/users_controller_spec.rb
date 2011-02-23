# -*- coding: utf-8 -*-
require 'spec_helper'

describe UsersController do
  render_views

  before(:each) do
    @user = Factory :user
  end

  after(:each) do
    User.delete_all
    Blog.delete_all
  end

  

  describe "GET 'home'" do

    before :each do
      @blogp = @user.create_primary_blog!
      @blogf = Factory :blog, :title => "founder blog"
      @blogm = Factory :blog, :uri =>Factory.next(:uri), :title => "member blog"
      @blogf1 = Factory :blog, :uri =>Factory.next(:uri), :title => "sub blog1"
      @blogf2 = Factory :blog, :uri =>Factory.next(:uri), :title => "sub blog2"
      @user.follow! @blogm, "member"
      @user.follow! @blogf, "founder"
      @user.follow! @blogf1, "follower"
      @user.follow! @blogf2, "follower"
      controller.sign_in @user
    end 
    
    it "should redirect to signin when no user sign in" do
      controller.sign_out
      get :show
      response.should redirect_to signin_path
    end

    it "should display home page when user sign in" do
      get :show
      response.should render_template 'show'
    end

    it "should show the user's blogs" do
      get :show
      response.should have_selector("div",
                                    :content => @blogp.title)
      response.should have_selector("div",
                                    :content => @blogf.title)
      response.should have_selector("div",
                                    :content => @blogm.title)
      response.should_not have_selector("div",
                                    :content => @blogf1.title)
    end

    it "should show the right following counts and link" do
      get :show
      response.should have_selector("a",
                                    :href => followings_path, 
                                    :content => "#{@user.subs.count}")
    end

    it "GET 'followings' should show the following blogs" do
      get :followings
      response.should have_selector("div",
                                    :content => @blogf1.title)
      response.should have_selector("div",
                                    :content => @blogf2.title)
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
  end
  
  describe "POST 'create'" do

    describe "failure" do
      before(:each) do
        @attr = {:name => "",
          :email => "",
          :password => "",
          :password_confirmation => ""}
      end

      it "should not create a user" do
        lambda {post :create, :user => @attr}.should_not change(User, :count)
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template 'new'
      end
    end

    describe "success" do
      before(:each) do
        @attr = {:name => "newuser",
          :email => "newuser@k.com",
          :password => "foobar",
          :password_confirmation => "foobar"}
      end

      it "should create a user" do
        lambda {post :create, :user => @attr}.should change(User, :count).by(1)
      end

      it "should redirece to home" do
        post :create, :user => @attr
        response.should redirect_to home_path
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should_not be_blank
      end

      it "should sign in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end

      it "should create primary blog" do
        post :create, :user => @attr
        user = User.where(:email => @attr[:email]).first
        user.primary_blog.uri.should == @attr[:name].downcase
        user.primary_blog.title.should == @attr[:name]
      end

      it "should translate chinese name to blog name" do
        post :create, :user => @attr.merge(:name => "李路")
        user = User.where(:email => @attr[:email]).first
        user.primary_blog.uri.should == "lilu"
      end

      it "should ljust name to uri length" do
        post :create, :user => @attr.merge(:name => "li")
        user = User.where(:email => @attr[:email]).first
        user.primary_blog.uri.should == "likk"
      end

      it "should change uri when uri exist" do
        Factory(:blog, :uri => "dupuri")
        post :create, :user => @attr.merge(:name => "dupuri")
        user = User.where(:email => @attr[:email]).first
        user.primary_blog.uri.should == "dupuri1"
      end

      it "should add uri number when uri exist" do
        Factory(:blog, :uri => "dupuri")
        Factory(:blog, :uri => "dupuri12")
        post :create, :user => @attr.merge(:name => "dupuri")
        user = User.where(:email => @attr[:email]).first
        user.primary_blog.uri.should == "dupuri13"
      end
    end

  end

  describe "GET 'edit'" do
    it "should deny access" do
      get :edit, :id => @user
      response.should redirect_to signin_path
    end

    it "should be successful" do
      controller.sign_in @user
      get :edit, :id => @user
      response.should render_template 'edit'
    end

  end

  describe "PUT 'update'" do

    describe "failure" do
      before(:each) do
        @attr = {:name => "",
          :email => "",
          :password => "",
          :password_confirmation => ""}
      end

      it "should deny access" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to signin_path
      end

      it "should render the 'edit' page" do
        controller.sign_in @user
        put :update, :id => @user, :user => @attr
        response.should render_template 'edit'
      end
    end

    describe "success" do
      before(:each) do
        @attr = {:name => "upuser",
          :email => "upuser@k.com",
          :password => "upfoobar",
          :password_confirmation => "upfoobar"}
        controller.sign_in @user
      end

      it "should change user's attribute" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should_not be_blank
      end

      it "should redirect to home" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to home_path
      end
    end

  end

end
