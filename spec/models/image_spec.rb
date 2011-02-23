require 'spec_helper'

describe Image, "create_from_original" do
  before :each do
    filename = Rails.root.join("test", "fixtures", "mxgs239.jpg")
    @file = File.open filename
    @image = Image.create_from_original(@file, large: [500, 800])
    @grid = Mongo::Grid.new Image.db
  end

  after :each do
    @file.close
  end


  describe "given an image file" do
    it "should provide original image" do
      @image.should be_kind_of(Image)
      @image._id.should_not be_nil
      @image.original.should_not be_nil

      f = @grid.get @image.original
      f.should_not be_nil
      f.content_type.should == 'image/jpeg'
    end

    it "should provide url for various versions" do
      url = @image.url_for :original
      url.should_not be_nil
      url.should =~ /#{@image.original.to_s}/
      url.should =~ /gridfs/

      url_large = @image.url_for :large
      url_large.should_not be_nil

      url_small = @image.url_for :small
      url_small.should be_nil
    end

    it "should do the resizing" do
      large_image = MiniMagick::Image.read(@grid.get(@image.large))
      dimensions = large_image['dimensions']
      dimensions[0].should <= 500
      dimensions[1].should <= 800
    end

    it "should not expose invalid version" do
      url = @image.url_for :description
      url.should be_nil
    end

  end
end

describe Image, "scaling calculation" do
  describe "Given specified from-to-result data" do
    it "should make it" do
      @data = [
        [[1000, 1000], [500, 800], [800, 800]],
        [[600, 600], [60, 0], [60, 60]],
      ]
      @data.each do |d|
        Image.calc_scale(d[0], d[1]).should == d[2]
      end
    end
  end
end

describe Image, "offset calculation" do
  describe "Given specified from-to-result data" do
    it "should make it" do
      @data = [
        [[800, 800], [500, 800], [150, 0]],
        [[600, 600], [60, 0], [270, 0]],
      ]
      @data.each do |d|
        Image.calc_offset(d[0], d[1]).should == d[2]
      end
    end
  end
end
