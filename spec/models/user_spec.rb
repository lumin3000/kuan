# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do

  before :each do
    @user = Factory :user
    @user.save!
    @attr = {:name => @user.name,
      :email => @user.email,
      :password => @user.password,
      :password_confirmation => @user.password_confirmation}
  end

  after :each do
    User.delete_all
  end
 
  describe "name validations" do
    it "should reject unvalid names" do
      names = [" ",
               "a"*11,
               "这一个超过十个字的名字"]
      names.each do |n|
        @user.name = n
        @user.should_not be_valid
      end
    end

    it "should accept valid names" do
      names = ["jyabkuan",
               "一个可以使用的名字"]
      names.each do |n|
        @user.name = n
        @user.should be_valid
      end
    end

  end

  describe "email validations" do
    it "should accept an valid email" do
      emails = %w[user@foo,com 错误@foo.org foo.bar@k.]
      emails.each do |e|
        @user.email = e
        @user.should_not be_valid
      end

      emails = %w[user@foo.com THE_USER@foo.org foo.bar@k.cn]
      emails.each do |e|
        @user.email = e
        @user.should be_valid
      end
    end

    it "should reject duplicate email" do
      user_dup = User.new(@attr)
      user_dup.should_not be_valid
      user_dup.email.upcase!
      user_dup.should_not be_valid
    end

  end

  describe "password validations" do
    it "should require a password" do
      @user.password = ""
      @user.should_not be_valid
    end

    it "should require matching confirmation" do
      @user.password_confirmation = "invalid"
      @user.should_not be_valid
    end

    it "should reject short or long passwords" do
      ps = ["a"*4, "a"*11]
      ps.each do |p|
        @user.password = @user.password_confirmation = p
        @user.should_not be_valid
      end
    end

  end

  describe "password encryption" do
    it "should have an encrypted password " do
      @user.should respond_to :encrypted_password
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    it "should match passwords" do
      @user.has_password?(@attr[:password]).should be_true
    end

    it "should not match error passwords" do
      @user.has_password?("invalid").should be_false
    end
  end

  describe "authentication" do
    it "should return nil for email not exist" do
      User.authenticate("none@k.com", "whatever").should == [nil, :email]
    end

    it "should return nil when email and password mismatch" do
      User.authenticate(@attr[:email], "wrongpass").should == [nil, :password]
    end

    it "should return the user when email and password match" do
      User.authenticate(@attr[:email], @attr[:password]).should == @user
    end
  end

end
