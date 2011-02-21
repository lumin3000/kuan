require 'spec_helper'

describe Image, "create_from_original" do
  describe "given an image file" do
    filename = Rails.root.join("test", "fixtures", "mxgs239.jpg")
    file = File.open filename
    subject { Image.create_from_original(file) }
    it "should provide original image" do
      subject.should be_kind_of(Image)
      subject._id.should_not be_nil
      subject.original.should_not be_nil

      grid = Mongo::Grid.new Image.db
      f = grid.get subject.original
      f.should_not be_nil
      f.content_type.should == 'image/jpeg'
    end

    it "should provide url for image" do
      url = subject.url_for :original
      url.should_not be_nil
      url.should =~ /#{subject.original.to_s}/
      url.should =~ /gridfs/
    end

    it "should not expose invalid version" do
      url = subject.url_for :description
      url.should be_nil
    end

  end
end
