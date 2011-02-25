require 'spec_helper'

describe "FriendlyNavs" do
  it "should nav to the requested page after signin" do
    user = Factory.create :user
    visit edit_user_path user
    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button
    response.should render_template 'users/edit' 
  end 
end
