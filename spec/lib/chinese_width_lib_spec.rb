# -*- coding: utf-8 -*-
require 'spec_helper'
require 'chinese/width'

describe Width do
  describe "half to full width translation" do
    it "should give correct str" do
      Width.instance.half2full("李路").should == "李路"
      Width.instance.half2full("leslie").should == "ｌｅｓｌｉｅ"
      Width.instance.half2full("123\n456").should == "１２３\n４５６"
      Width.instance.half2full("# @ !", ['#']).should == "#　＠　！"
    end
  end
end
