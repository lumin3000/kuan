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
      a.count.should == 4
      a.first.should == "1234567890ab"
      a[1].should == "cdefg"
      a[2].should == "1234567890ab"
      a[3].should == "cd" 
    end

    it "should give correct lines with #" do
      str = "123456#789#0ab#cde#fgh#ijk#lmn#op#qrstuvw#xyz" 
      a = @ct.wrap_lines str
      a.count.should == 3
      a[0].should == "123456#789#0ab"
      a[1].should == "#cde#fgh#ijk#lmn"
      a[2].should == "#op#qrstuvw#xyz"
    end
  end
end
