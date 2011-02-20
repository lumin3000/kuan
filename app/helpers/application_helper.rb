module ApplicationHelper
  def render_post(p)
    type = p.class.to_s.downcase!
    template = "posts/#{type}"
    render partial: "posts/post", object: p,
      locals: { sub_template: template }
  end

  def js(*files)
    @js = [] if @js.nil?
    files.each do |f|
      @js << capture do
        f
      end
    end
  end
end
