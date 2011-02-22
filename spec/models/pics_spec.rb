describe Pics do
  before :all do
    @images = Image.limit(2).all.to_ary
    raise "not enouuuuuuuuuuuuuuuuugh" if @images.length < 2
    params = {
      photos: [
        {image: @images[0].id.to_s, desc: "Photo1"},
        {image: @images[1].id.to_s, desc: "yet another photo"},
      ],
      content: "Blah"
    }
    @post = Pics.new(params)
  end

  describe "Given a params hash from client" do
    it "should create a complete pics model" do
      @post.should be_valid
      @post.save.should be_true

      image = @post.photos[0].image
      url = image.url_for(:original)
      url.should be_kind_of(String)
      url.should be_include(image.original.to_s)

      posts = Post.all.to_ary
      posts.should be_include(@post)
    end
  end

  describe "Given a param for existing pics" do
    it "should be able to update" do
      @post.update_attributes!({
        photos: [{image: @images[1].id.to_s, desc: ""}],
        content: "",
      })
      @post.reload
      @post.photos.length.should == 1
      @post.photos[0].desc.should be_empty
      @post.content.should be_empty
    end
  end
end
