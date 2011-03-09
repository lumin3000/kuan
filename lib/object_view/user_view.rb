class UserView
  include ObjectView

  def initialize(user, extra = {})
    @user = user
    @extra = extra
  end

  expose :@user, :name

  def user_url
    @primary_blog ||= @user.primary_blog
    @extra[:url_template] % @primary_blog.uri if @extra.has_key? :url_template
  end

  { 180 => :large,
    60 => :medium,
    24 => :small, }.each do |k, v|
    define_method("avatar_#{k}") do
      @user.primary_blog.icon.url_for(v)
    end
  end
end
