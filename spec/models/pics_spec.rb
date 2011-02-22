describe Pics do
  describe "Given a params hash from client" do
    it "should create a complete pics model" do
      @images = Image.limit(2).all.to_ary
      raise "not enouuuuuuuuuuuuuuuuugh" if @images.length < 2
      @params = {
        photos: [
          {image: @images[0].id.to_s, desc: "Photo1"},
          {image: @images[1].id.to_s, desc: "yet another photo"},
        ],
        content: "Blah"
      }
      @post = Pics.create(@params)
      @post.should be_valid

      image = @post.photos[0].image
      url = image.url_for(:original)
      url.should be_kind_of(String)
      url.should be_include(image.original.to_s)

      posts = Post.all.to_ary
      posts.should be_include(@post)
    end
  end
end
