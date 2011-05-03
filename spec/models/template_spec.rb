require 'spec_helper'

describe Template do
  describe "Given a valid instance" do
    before :each do
      @author = Factory :user_unique
      @tpl = Template.new
      @tpl.author = @author
      @tpl.name = 'fuzzy template'
    end

    it "shouldn't be present as public" do
      @tpl.save!
      Template.find_public.should_not be_include @tpl
    end

    describe "when we mark it as public" do
      before :each do
        @tpl.public = true
      end

      describe "and give it a thumbnail" do
        before :each do
          File.open 'test/fixtures/mxgs239.jpg', 'rb' do |f|
            Image.create_from_original f
          end
          @tpl.thumbnail = Image.first
        end

        after :each do
          Image.destroy_all
        end

        it "should be present in template selection page" do
          @tpl.save!
          templates = Template.find_public
          templates.should_not be_empty
          templates.should be_include(@tpl)
        end
      end
    end
  end
end
