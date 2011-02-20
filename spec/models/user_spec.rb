# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do

  before(:each) do
    @attr = {:name => "Test user", :email => "u1@k.com"}
    @user = User.new(@attr)
  end

  after(:each) do
    User.delete_all
  end

  it "should accept a valid name" do
    names = [" ",
             "a"*11,
             "这一个超过十个字的名字"]
    names.each do |n|
      @user.name = n
      @user.should_not be_valid
    end

    names = ["jyabkuan",
             "一个可以使用的名字"]
    names.each do |n|
      @user.name = n
      @user.should be_valid
    end

  end

  it "should require an valid email" do
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
    user = User.create!(@attr)
    user_dup = User.new(@attr)
    user_dup.should_not be_valid
    user_dup.email.upcase!
    user_dup.should_not be_valid
  end
 
end
