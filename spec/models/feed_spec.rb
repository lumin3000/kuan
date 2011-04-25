require 'spec_helper'

describe Feed do
  describe "Importing a feed" do
    before :each do
      @user = Factory.build(:user_unique)
      @blog = @user.create_primary_blog!
    end

    after :each do
      Blog.delete_all
      Feed.delete_all
    end

    it "should record an importing relationship" do
      feed_uri = "http://9tonight.blogbus.com/index.rdf"
      type = :pic
      @blog.import! feed_uri, type
      @blog.reload
      @blog.import_feeds.first.as_type.should == type
      @blog.import_feeds.first.should be_is_new
      @blog.import_feeds.first.feed.uri.should == feed_uri
      @blog.import_feeds.first.feed.imported_count.should == 1
      @blog.import_feeds.first.feed.title.should == "Silence" 
    end

    it "should accept an uri which omit http protocol" do
      uri = "9tonight.blogbus.com/index.rdf"
      feed = Feed.find_or_create_by :uri => uri
      feed.should be_valid
    end

  end
end
