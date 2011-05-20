# -*- coding: utf-8 -*-
require 'spec_helper'
require 'kdt/colortext'

describe ColorText do
  describe "Wrap lines" do
    before :each do
      @ct = ColorText.new
    end
    
    it "should give correct lines" do
      str = "12345678"
      a = @ct.wrap_lines str 
      a.count.should == 1
      a.first.should == "12345678" 
    end

    it "should give correct lines with wrap" do
      str = "1234567890abcdefg\n1234567890abcd"
      a = @ct.wrap_lines str 
      a.count.should == 3
      a.first.should == "1234567890abcd"
      a[1].should == "efg"
      a[2].should == "1234567890abcd"
    end

    it "should give correct lines with #" do
      str = "123456#789#0ab#cde#fgh#ijk#lmn#op#qrstuvw#xyz" 
      a = @ct.wrap_lines str
      a.count.should == 3
      a[0].should == "123456#789#0ab#cd"
      a[1].should == "e#fgh#ijk#lmn#op#qr"
      a[2].should == "stuvw#xyz"
    end

    it "should give correct lines with # wrap" do
      str = "#时间会把一个人的感情磨平， 然后所有的期待，想象随之消失。#\n就是这样，只言片语不知如何诉说。"
      a = @ct.wrap_lines str
      a.count.should == 5
      a[0].should == "#时间会把一个人的感情磨平， "
      a[1].should == "然后所有的期待，想象随之消失"
      a[2].should == "。#"
      a[3].should == "就是这样，只言片语不知如何诉"
      a[4].should == "说。"
    end
  end
end
