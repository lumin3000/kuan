require 'spec_helper'

describe "LayoutRoutes" do
  it "should have a signup page at '/signup'" do
    get 'signup'
    response.should be_success
  end
end
