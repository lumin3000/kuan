require 'spec_helper'

describe Video do
  describe "Given an instance" do
    before :each do
      @video = Video.new
    end

    describe "Massive assignment :url => '.swf'" do
      before :each do
        @url =  "foo.swf"
        @video = Video.new({
          :url => @url
        })
      end

      describe "when url ends with .swf" do
        it "should not worry too much" do
          @video.player.should == @url
        end
      end
    end
  end
end
