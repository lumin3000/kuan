# -*- coding: utf-8 -*-
require 'spec_helper'

describe UsersController do
  render_views

  before(:each) do
    @user = Factory :user
  end

  after(:each) do
    User.delete_all
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "should redirect to signin when no user sign in" do
      get :show
      response.should redirect_to signin_path
    end

    it "should display home page when user sign in" do
      controller.sign_in @user
      get :show
      response.should render_template 'show'
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
        @attr = {:name => "new user", 
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
