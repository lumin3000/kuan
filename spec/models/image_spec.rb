require 'spec_helper'

describe Image, "create_from_original" do
  describe "given an image file" do
    filename = Rails.root.join("test", "fixtures", "mxgs239.jpg")
    subject { Image.create_from_original(filename) }
    it "should provide thumbnails" do
      subject.should be_kind_of(Image)
      subject._id.should_not be_nil
      subject.original.should_not be_nil
    end
  end
end
