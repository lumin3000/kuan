require 'uri'

module ApplicationHelper
  def js(*files)
    @js = [] if @js.nil?
    files.each do |f|
      @js << capture do
        f
      end
    end
  end

  def css(*files)
    @css = [] if @css.nil?
    files.each do |f|
      @css << capture do
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

  def pagination(collection, options = {})
    options = { :per_page => 10, }.update(options)

    if m = %r{page/(\d+)/?$}.match(request.url)
      current_page, base_url = m[1].to_i(10), m.pre_match
    else
      current_page, base_url = 1, request.url
    end
    current_page = current_page
    base_url.sub! %r{/?$}, ""
    render :partial => 'shared/pagination', :locals => {
      :current_page => current_page,
      :base_url => base_url,
      :collection => collection,
    }.update(options)
  end
  
  def pagination_standard(options = {})
    options = { max_page: 10, show_page: 10, default_position: 4 }.update(options)

    if m = %r{page/(\d+)/?$}.match(request.url)
      current_page, base_url = m[1].to_i(10), m.pre_match
    else
      current_page, base_url = 1, request.url
    end
    current_page = current_page
    base_url.sub! %r{/?$}, ""

    if current_page < options[:default_position]
      start_page = 1
    elsif current_page > options[:max_page] - options[:show_page] + options[:default_position] - 1
      start_page = options[:max_page] - options[:show_page] + 1
    else
      start_page = current_page - options[:default_position] + 1
    end
    
    end_page = start_page + options[:show_page] - 1

    render partial: "shared/pagination_standard", locals: {
      current_page: current_page,
      start_page: start_page,
      end_page: end_page,
      base_url: base_url,
    }
  end
end
