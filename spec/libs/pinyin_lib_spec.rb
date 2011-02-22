# -*- coding: utf-8 -*-
require 'spec_helper'
require 'pinyin'

describe PinYin do
  describe "pinyin translation" do
    it "should give correct pinyin" do
      PinYin.instance.to_pinyin("李路").should == "lilu" 
    end
  end
end
