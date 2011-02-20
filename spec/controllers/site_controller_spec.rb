require 'spec_helper'

describe SiteController do

  describe "GET 'public_timeline'" do
    it "should be successful" do
      get 'public_timeline'
      response.should be_success
    end
  end

end
