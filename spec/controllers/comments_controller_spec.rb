require 'spec_helper'

describe CommentsController do
  render_views
  
  before :each do
  end

  after :each do
  end

  describe "access control" do
  end

  describe "POST 'create'" do
    before :each do
      controller.singn_in @user
    end
  end

  describe "GET index" do
    it "should show comments list" do
    end
  end

end
