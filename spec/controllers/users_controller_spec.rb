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

end
