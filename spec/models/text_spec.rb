require 'spec_helper'

describe Text do
  before :all do
    @blog = Factory :blog, :uri => Factory.next(:uri)
    owage = Factory :following, {
      auth: "founder",
      blog: @blog,
    }
    @founder = Factory :user, :followings => [owage], :email => Factory.next(:email)

    attendance = Factory :following, {
      auth: "member",
      blog: @blog,
    }
    @member = Factory :user, :followings => [attendance], :email => Factory.next(:email)

    primary_blog = Factory :following, {
      auth: "lord",
      blog: @blog,
    }
    @lord = Factory :user, :followings => [primary_blog], :email => Factory.next(:email)

    @params = {
      blog_id: @blog.id.to_s,
      author_id: @founder.id.to_s,
    }
  end

  describe "Given a new blog post" do
    before :all do
      @text = Text.new(@params.dup.update({
        content: "not very long", title: "hi there",
      }))
    end

    it "should be valid" do
      @text.should be_valid
    end
  end

  describe "Given an empty blog post" do
    subject do
      Text.new @params.update({
        content: "",
        title: "I'm empty!",
      })
    end

    it "should not validate" do
      should_not be_valid
    end
  end

  describe "Given a post without author" do
    it "should not validate" do
      @text = Text.new({
        content: "whatever",
        blog_id: @blog.id,
      })
      @text.should_not be_valid
    end
  end

  describe "Given a post without target blog" do
    it "should not validate" do
      @text = Text.new({
        content: "whatever",
        author_id: @founder.id,
      })
    end
  end

  describe "Given a post in attended blog" do
    it "should not be editable by the user" do
      @post = Text.create!(@params.dup.update({
        content: "blah",
      }))

      @post.should_not be_editable_by(@member)
    end

    describe "stuff posted by member" do
      before :all do
        @post_by_member = Text.create!(@params.dup.update({
          content: "my two cents",
          author_id: @member.id.to_s,
        }))
      end

      it "should be editable by founder" do
        @post_by_member.should be_editable_by(@founder)
      end

      it "should be editable by lord" do
        @post_by_member.should be_editable_by(@lord)
      end
    end
  end

  describe "Given a follower of the blog" do
    it "should not be able to post stuff" do
      following = Factory :following, {
        :auth => "follower",
        :blog => @blog,
      }
      @follower = Factory :user, :followings => [following],
        :email => Factory.next(:email)
      @post = Text.new({
        content: "messing around",
        author_id: @follower.id.to_s,
        blog_id: @blog.id.to_s,
      })
      @post.should_not be_valid
    end
  end
end
