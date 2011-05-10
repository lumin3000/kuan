require 'spec_helper'

describe Category do
  before :each do
    @blog = Factory.build(:blog_unique)
    @category = Category.new()
    @category.name = "tt"
    @category.save!
  end
  after :each do
  end

  describe "display category" do
    it "should get top categories" do
      Category.top_categories.length.should == 0
      @category.top = true
      @category.save!
      Category.top_categories.length.should == 1
    end
  end
end
