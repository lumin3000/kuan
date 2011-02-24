require 'spec_helper'

describe Pics do
  before :all do
    @images = []
    10.times do
      @images << Image.create
    end
    @user = Factory.build :user
    @blog = Factory.build :blog

    @param = {
      author_id: @user.id.to_s,
      blog_id: @blog.id.to_s,
    }

    params = @param.dup.update({
      photos: [
        {image: @images[0].id.to_s, desc: "Photo1"},
        {image: @images[1].id.to_s, desc: "yet another photo"},
      ],
      content: "Blah",
    })
    @post = Pics.new(params)
    @old_photo = @post.photos
  end

  describe "Given a params hash from client" do
    it "should create a complete pics model" do
      pending "unable to sort this out"
      @post.should be_valid
      @post.save.should be_true

      image = @post.photos[0].image

      posts = Post.all.to_ary
      posts.should be_include(@post)
    end
  end

  describe "Given a param for existing pics" do
    it "should be able to update" do
      pending "unable to sort this out"
      @post.update_attributes!({
        photos: [
          {image: @images[1].id.to_s, desc: ""},
          {image: @images[0].id.to_s, desc: ""},
          {id: @old_photo[1].id.to_s, image: @images[1].id.to_s, desc: ""},
        ],
        content: "",
      })
      @post.reload
      @post.photos.length.should == 3
      @post.photos[0].desc.should be_empty
      @post.photos[0].image.should be_kind_of(Image)
      @post.content.should be_empty
    end
  end

  describe "Given an empty array lack of old photos" do
    it "should delete missing photos" do
      pending "unable to sort this out"
      @post.update_attributes!({
        photos: [
          {image: @images[0].id},
        ],
      })
      @post.reload
      @post.photos.length.should == 1
    end
  end
end
