require 'spec_helper'

describe "Users" do

  before(:each) do
  end

  after(:each) do
    User.delete_all
  end

  describe "signup" do
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

  describe "sign in/out" do
    it "should sign a user in and out" do
      user = Factory :user
      user.create_primary_blog! 
      visit signin_path
      fill_in :email, :with => user.email
      fill_in :password, :with => user.password
      click_button
      controller.should be_signed_in
      #expect a signout link
    end
  end
end
