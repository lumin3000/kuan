require 'spec_helper'

describe Post do
  describe "notice watchers when usre comment a post" do
    before :each do
      @blog = Factory.build(:blog_unique)
      @following = Factory.build(:following_lord, :blog => @blog)
      @user = Factory.build(:user_unique, :followings => [@following])
      @comment_author = Factory.build(:user_unique)
      @comment_user = Factory.build(:user_unique)
      @post = Post.new
      @post.author = @user
    end

    it "should notice post author" do
      length = @user.comments_notices.unreads.count
      @comment = Factory.build(:comment, :post => @post, :author => @comment_author)
      @post.notify_watchers(@comment)
      @user.comments_notices.unreads.count.should == length + 1
    end

    it "should notice other comment user" do
      @comment_old = Factory.build(:comment, :post => @post, :author => @comment_user)
      length = @comment_user.comments_notices.unreads.count
      @comment = Factory.build(:comment, :post => @post, :author => @comment_author)
      @post.notify_watchers(@comment)
      @comment_user.comments_notices.unreads.count.should == length + 1
    end

    it "should not notice self" do
      @comment_old = Factory.build(:comment, :post => @post, :author => @comment_user)
      length = @comment_author.comments_notices.unreads.count
      @comment = Factory.build(:comment, :post => @post, :author => @comment_author)
      @post.notify_watchers(@comment)
      @comment_author.comments_notices.unreads.count.should == length
    end

    it "should not notice same user twice" do
      Factory.build(:comment, :post => @post, :author => @comment_user)
      Factory.build(:comment, :post => @post, :author => @comment_user)
      length = @comment_user.comments_notices.unreads.count
      @comment = Factory.build(:comment, :post => @post, :author => @comment_author)
      @post.notify_watchers(@comment)
      @comment_user.comments_notices.unreads.count.should == length + 1
    end

    it "should list all watchers" do
      @comment = Comment.new
      @comment.post = @post
      @comment.author = @comment_user
      @comment.save
      watchers = @post.watchers
      watchers.should be_include(@post.author)
      watchers.should be_include(@comment_user)
    end
  end

  describe "list news" do
    before :each do
      Post.delete_all
      Blog.delete_all

      @blog = Factory.build(:blog_unique)
      @following = Factory.build(:following_lord, :blog => @blog)
      @blog_private = Factory.build(:blog_unique)
      @following_private = Factory.build(:following_lord, :blog => @blog_private)
      @blog_new = Factory.build(:blog_unique)
      @following_new = Factory.build(:following_lord, :blog => @blog_new)
      @user = Factory.build(:user_unique, :followings => [@following, @following_private, @following_new] )
      @post = Factory.build(:text)
      @user.save
      @blog.save

      @blog_private.private = true
      @blog_private.save

      @blog_new.save

      @post.author = @user
      @post.blog = @blog
      @post.created_at = 1.hour.ago
      @post.save!
      @blog.reload
      @pagination = {
        :page => 1,
        :order => "posted_at DESC",
        :per_page => 999,
      }
    end
    it "should order desc" do
      @post_new = Factory.build(:text)
      @post_new.author = @user
      @post_new.blog = @blog_new
      @post_new.save!
      @blog_new.reload

      @news = Post.news(@pagination)
      @news.first.should == @post_new
      @news.last.should == @post
    end
    it "should not show private" do
      @post_private = Factory.build(:text)
      @post_private.author = @user
      @post_private.blog = @blog
      @post_private.save

      @news = Post.news(@pagination)
      @news.length.should == 1
    end

    it "should handle when all posts in blog was deleted" do
      @post.destroy
      @news = Post.news(@pagination)
      @news.length.should == 0
    end
  end

  describe "list wall" do
    before :each do
      Post.delete_all
      Blog.delete_all

      @blog = Factory.build(:blog_unique)
      @following = Factory.build(:following_lord, :blog => @blog)
      @user = Factory.build(:user_unique, :followings => [@following] )
      @post = Factory.build(:text)
      @user.save
      @blog.save

      @post.author = @user
      @post.blog = @blog
      @post.save!
      @blog.reload
    end

    it "should show posts" do
      Post.wall.first.class.should == Text
      Post.wall.length.should > 0
    end
  end


  describe "create a post" do
    it "should update blog posted_at" do
      @blog = Factory.build(:blog_unique)
      @following = Factory.build(:following_lord, :blog => @blog)
      @user = Factory.build(:user_unique, :followings => [@following] )
      @user.save!
      @blog.save!
      @post = Factory.build(:text)
      @post.author = @user
      @post.blog = @blog
      @post.save!
      @blog.reload
      
      @blog.posted_at.should == @post.created_at
    end
  end
end

describe Post, "reposting" do
  before :each do
    @blog = Factory :blog_unique
    @user = Factory :user_unique
    @user.follow! @blog, "lord"
    @post = Text.new(:content => "For reposting")
    @post.author = @user
    @post.blog = @blog
    @post.save
    @re_blog = Factory :blog_unique
    @re_user = Factory :user_unique

    @re_user.follow! @re_blog, "founder"
  end

  describe "for success" do
    before :each do
      @repost = @post.dup
      @repost.blog = @re_blog
      @repost.author = @re_user
      @repost.parent = @post
      @repost.save 
      @repost.reload
      @repost_next = @repost.dup
      @repost_next.parent = @repost
      @repost_next.save
      @repost_next.reload
    end

    it "should create a new repost" do
      @repost.parent.should == @post
      @repost.ancestor.should == @post
      @repost.content.should == @post.content
      @repost.author.should == @re_user
      @repost.blog.should == @re_blog
      @repost.parent.blog.should == @blog
    end

    it "should have a correct anccestor" do
      @repost_next.parent.should == @repost
      @repost_next.ancestor.should == @post
    end

    it "ancestor should have correct reposts count" do
      @post.reload
      @post.repost_count.should == 2
    end

    it "should not be repost when parent is deleted" do
      @repost.delete
      @repost_next.reload
      @repost_next.parent.should be_nil
    end

    it "should use parent as ancestor when ancestor is deleted" do
      @post.delete
      @repost_next.reload
      @repost_next.ancestor.should == @repost
    end
  end
end

describe Post, "Rich text filtering" do
  before :each do
    email = Factory.next :email
    uri = Factory.next :uri
    @author = Factory :user, email: email
    @blog = Factory :blog, uri: uri
    @author.follow! @blog, "founder"
    @post = Factory.build :text, author: @author, blog: @blog
  end

  describe "given a simple rich text input with every tag and attr in whitelist" do
    before :each do
      @orig_content = '<a href="http://g.cn" shit="true">blah</a>'
      @expected = '<a href="http://g.cn">blah</a>'
      @post.content = @orig_content
    end

    it "should not mess it up but strip junk" do
      @post.save!
      @post.reload
      @post.content.should == @expected
    end
  end

  describe "given a text input with nothing but malicious" do
    before :each do
      @orig_content = <<EOF
<script type="text/javascript">alert("you fool!")<script>
EOF
      @post.content = @orig_content
      @post.save!
      @post.reload
    end

    it "should trim it to empty" do
      @post.content.should be_blank
    end
  end

  describe "given a plain text input" do
    before :each do
      @orig_content = @post.content
    end

    describe "and save it" do
      before :each do
        @post.save!
        @post.reload
      end

      it "should not mess it up" do
        @post.content.should == @orig_content
      end
    end
  end

  describe "let's play with M$ style expressions" do
    before :each do
      @orig_content = '<p style="text-decoration: underline; width: expression(alert(\'yeeha\'))">!</p>'
      @expected = '<p style="text-decoration: underline">!</p>'
      @post.content = @orig_content
    end

    it "should clean it up" do
      @post.save!
      @post.reload
      @post.content.should == @expected
    end
  end

  describe "funcky url?" do
    before :each do
      @orig_content = '<img src="j&amp;97;vascript:alert(document.cookie) />"'
      @expected = '<img src="">'
      @post.content = @orig_content
    end

    it "should clean it up" do
      @post.save!
      @post.reload
      @post.content.should == @expected
    end
  end

  describe "given a raw url post" do
    before :each do
      @orig_content = 'http://g.cn'
      @expected = '<a href="http://g.cn">http://g.cn</a>'
      @post.content = @orig_content
      @post.save!
      @post.reload
    end

    it "should wrap <a> around it" do
      @post.content.should == @expected
    end

    describe "but not again!" do
      it "should do nothing further" do
        content = @post.content
        @post.content = content
        @post.save!
        @post.reload
        @post.content.should == content
      end
    end
  end
end
