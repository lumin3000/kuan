class UserView
  extend Forwardable
  include ObjectView

  def initialize(user, extra = {})
    @user = user
    @extra = extra
  end

  def_delegators :@user, :name

  def url
    @primary_blog ||= @user.primary_blog
    @extra[:url_template] % @primary_blog.uri
  end
end
