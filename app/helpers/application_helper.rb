module ApplicationHelper
  def js(*files)
    @js = [] if @js.nil?
    files.each do |f|
      @js << capture do
        f
      end
    end
  end

  def use_header(t)
    if(t.nil?)
      render partial: "layouts/header"
    else
      render partial: "layouts/header_#{t}"
    end
  end
  
  def server_name
    ".kuandom.com"
  end
end
