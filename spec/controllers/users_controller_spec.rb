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
      # deprecated waitting for real page
      # response.should have_selector("a",
      #                               :href => followings_path, 
      #                               :content => "#{@user.subs.count}")
    end
 
    it "GET 'followings' should show the following blogs" do
      get :followings
      response.should have_selector("div",
                                    :content => @blogf1.title)
      response.should have_selector("div",
                                    :content => @blogf2.title)
    end

    it "should give default blog for passing uri" do
      get :show, :uri => @blogm.uri
      # deprecated waitting for real page
      # response.should have_selector("div.default_blog",
      #                               :content => @blogm.title)
    end

    it "should give primary blog for not passing uri" do
      get :show
      # deprecated waitting for real page
      # response.should have_selector("div.default_blog",
      #                               :content => @blogp.title)
    end

    it "should give default blog followers count and link" do
      user1 = Factory :user, :email => Factory.next(:email)
      user2 = Factory :user, :email => Factory.next(:email)
      user1.follow! @blogp
      user2.follow! @blogp
      get :show
      # commented by lilu, waitting for real page implenation
      # response.should have_selector("a",
      #                               :href => followers_blog_path(@blogp), 
      #                               :content => "#{@blogp.followers_count}") 
    end

  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new, :code => @user.inv_code
      response.should be_success
    end

    it "blank code should render invalid_invitation page" do
      get :new
      #response.should render_template 'invalid_invitation'
    end

    it "error code should render invalid_invitation page" do
      get :new, :code => "invalid"
      #response.should render_template 'invalid_invitation'
    end
  end 
  
  describe "POST 'create'" do

    describe "failure" do
      before(:each) do
        @attr = {:name => "",
          :email => "",
          :password => "",
          :password_confirmation => ""}
        @code = @user.inv_code
      end

      it "error code should render invalid_invitation page" do
        post :create, :code => "invalid"
        #response.should render_template 'invalid_invitation'
      end

      it "should not create a user" do
        lambda {post :create, :user => @attr, :code => @code}.should_not change(User, :count)
      end

      it "should render the 'new' page" do
        post :create, :user => @attr, :code => @code
        response.should render_template 'new'
      end
    end

    describe "success" do
      before(:each) do
        @attr = {:name => "newuser",
          :email => "newuser@k.com",
          :password => "foobar",
          :password_confirmation => "foobar"}
        @code = @user.inv_code
      end

      it "should create a user" do
        lambda {post :create, :user => @attr, :code => @code}.should change(User, :count).by(1)
      end

      it "should redirece to home" do
        post :create, :user => @attr, :code => @code
        response.should redirect_to home_path
      end

      it "should have a welcome message" do
        post :create, :user => @attr, :code => @code
        flash[:success].should_not be_blank
      end

      it "should sign in" do
        post :create, :user => @attr, :code => @code
        controller.should be_signed_in
      end

      it "should create primary blog" do
        post :create, :user => @attr, :code => @code
        user = User.where(:email => @attr[:email]).first
        user.primary_blog.uri.should == @attr[:name].downcase
        user.primary_blog.title.should == @attr[:name]
      end

      it "should translate chinese name to blog name" do
        post :create, :user => @attr.merge(:name => "李路"), :code => @code
        user = User.where(:email => @attr[:email]).first
        user.primary_blog.uri.should == "lilu"
      end

      it "should ljust name to uri length" do
        post :create, :user => @attr.merge(:name => "li"), :code => @code
        user = User.where(:email => @attr[:email]).first
        user.primary_blog.uri.should == "likk"
      end

      it "should truncate name to uri length" do
        post :create, :user => @attr.merge(:name => "中国科技资源共享网"), :code => @code
        user = User.where(:email => @attr[:email]).first 
        user.primary_blog.uri.should == "zhongguokejiziyuangongxiangwan"
      end

      it "should change uri when uri exist" do
        Factory(:blog, :uri => "dupuri")
        #very important! for creating this blog
        Factory(:blog, :uri => "dupurixxx")
        post :create, :user => @attr.merge(:name => "dupuri"), :code => @code
        user = User.where(:email => @attr[:email]).first
        user.primary_blog.uri.should == "dupuri1"
      end

      it "should add uri number when uri exist" do
        Factory(:blog, :uri => "dupuri")
        Factory(:blog, :uri => "dupuri12")
        post :create, :user => @attr.merge(:name => "dupuri"), :code => @code
        user = User.where(:email => @attr[:email]).first
        user.primary_blog.uri.should == "dupuri13"
      end

      it "should follow inv_user's open blogs" do
        bf = Factory(:blog, :uri => "invuri")
        @user.follow! bf, "founder"
        bm = Factory(:blog, :uri => "invuri2")
        @user.follow! bm, "member"
        bp = Factory(:blog, :uri => "private-blog-you-wont-see", :private => true)
        @user.follow! bp, "founder"
        post :create, :user => @attr, :code => @code
        user = User.where(:email => @attr[:email]).first
        user.subs.should be_include bf
        user.subs.should be_include bm
        user.subs.should_not be_include bp
      end

      it "should follow administrator's blogs" do
        blog = Factory(:blog, :uri => "kuaniao")
        post :create, :user => @attr, :code => @code
        user = User.where(:email => @attr[:email]).first
        user.subs.should include blog
      end

      it "should not follow administrator's blogs" do
        post :create, :user => @attr, :code => @code
        user = User.where(:email => @attr[:email]).first
        user.subs.should be_empty
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
