require 'spec_helper'

describe "Users" do

  before(:each) do
  end

  after(:each) do
    User.delete_all
  end

  describe "signup" do
    describe "failure" do
      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in :name, :with => ""
          fill_in :email, :with => ""
          fill_in :password, :with => ""
          fill_in "Password confirmation", :with => ""
          click_button
          response.should render_template 'users/new'
          response.should have_selector "div#user_error_explanation"
        end.should_not change(User, :count)
      end 
    end

    describe "success" do
      it "should make a new user" do
        lambda do
          visit signup_path
          fill_in :name, :with => "newuser"
          fill_in :email, :with => "newuser@k.com"
          fill_in :password, :with => "foobar"
          fill_in "Password confirmation", :with => "foobar"
          click_button
          response.should render_template 'users/show'
          response.should have_selector "div.flash_users_success"
        end.should change(User, :count).by(1)
      end
    end
  end

end
