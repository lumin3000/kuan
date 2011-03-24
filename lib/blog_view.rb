# encoding: utf-8

module ObjectView
  require 'nokogiri'
  require 'cgi'

  def self.wrap(obj, extra = {})
    (obj.class.name + "View").constantize.new(obj, extra)
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def respond_to?(method)
    return true if self.singleton_methods.include? method
    klass = self.class
    begin
      return true if klass.public_instance_methods(false).include? method
      klass = klass.superclass
    end while klass.name[-4..-1] == 'View'
    false
  end

  module ClassMethods
    def expose_without_escape(prop_name, *fields)
      fields.each do |f|
        define_method(f) do
          prop = instance_variable_get prop_name
          value = prop.send(f)
          value.nil? ? ''.html_safe : value.html_safe
        end
      end
    end

    def expose_by_dict(prop_name, dict)
      dict.each do |k, v|
        define_method(v) do
          prop = instance_variable_get prop_name
          value = prop.send k
          value.nil? ? ''.html_safe : h(value)
        end
      end
    end

    def expose(prop_name, *fields)
      fields.each do |f|
        define_method(f) do
          prop = instance_variable_get prop_name
          value = prop.send f
          value.nil? ? ''.html_safe : h(value)
        end
      end
    end
  end

  private
  # RAILS
  def h(str)
    return ''.html_safe if str.nil?
    str.html_safe? ? str : CGI.escapeHTML(str).html_safe
  end
  # Y U NO EASY TO REUSE

  def self.js_tag(name)
    name = name.to_s
    file = "public/javascripts/#{name}.js"
    timestamp = File.stat(Rails.root + file).mtime.to_i
    "<script type='text/javascript' src='/javascripts/#{name}.js?#{timestamp}'></script>"
  end

  JS_CODE = <<EOF.html_safe
    #{ObjectView.js_tag('mootools-core')}
    #{ObjectView.js_tag('rails')}
    #{ObjectView.js_tag('mootools-more')}
    #{ObjectView.js_tag('application')}
EOF

  def load_js()
    return '' if @extra[:js]
    @extra[:js] = true
    JS_CODE
  end
end

class BlogView < Mustache
  include ObjectView

  VALUE_PARSERS = {
    'bool' => lambda { |v|
      case v
      when 1
        true
      when /1|true|on|yes/i
        true
      when 0
        false
      when /0|false|off|no/i
        false
      else
        raise "dunno: #{v}"
      end
    },
    'color' => lambda {|v| v},
    'text' => lambda {|v| v},
    'image' => lambda {|v| v},
  }

  def self.parse_custom_vars(str)
    result = {'color' => {}, 'image' => {}, 'text' => {}, 'bool' => {}}
    str.split(/\r\n?|\n/).each do |rule|
      pieces = rule.strip.split($;, 4)
      next if pieces.length != 4
      type = pieces[0]
      next if not self::VALUE_PARSERS.has_key? type
      result[type][pieces[1]] = {
        'desc' => pieces[2],
        'value' => self::VALUE_PARSERS[type].call(pieces[3]),
      }
    end
    result
  end

  def self.extract_variables(blog)
    EXTRACTOR.blog = blog
    EXTRACTOR.template = blog.template_in_use
    EXTRACTOR.render
    EXTRACTOR.variables || {
        'color' => {
        },
        'bool' => {
        },
        'text' => {
        },
        'image' => {
        },
      }
  end

  def escapeHTML(str)
    str.html_safe? ? str : CGI.escapeHTML(str)
  end

  def initialize(blog, extra = {})
    @blog = blog
    @posts = extra[:posts] && extra[:posts].map {|p| ObjectView.wrap(p, extra)}
    @url_template = extra[:url_template]
    @extra = extra
    self.template = blog.template_in_use
  end

  expose :@blog, :title
  expose_without_escape :@blog, :desc

  def meta_desc
    h(Nokogiri::HTML.fragment(desc).inner_text)
  end

  def custom_css
    "<style type='text/css'>#{h @blog.custom_css}</style>".html_safe
  end

  def posts
    @posts
  end

  def post_single
    @extra[:post_single]
  end

  def post_index
    ! @extra[:post_single]
  end

  def url
    @url_template && h(@url_template % @blog.uri)
  end

  def home_url
    @url_template && h(@url_template % 'www')
  end

  { 180 => :large,
    60 => :medium,
    128 => :'128',
    96 => :'96',
    64 => :'64',
    48 => :'48',
    40 => :'40',
    30 => :'30',
    16 => :'16',
    24 => :small, }.each do |k, v|
    define_method("icon_#{k}") do
      h(@blog.icon.url_for(v))
    end
  end

  def is_primary
    @blog.primary?
  end

  def followings
    @blog.lord.subs.map {|b| BlogView.new(b, @extra)} if has_following
  end

  def has_following
    is_primary && !@blog.lord.subs.blank?
  end

  def other_pages
    return nil unless has_other_pages
    fetch_other_pages
    @other_pages
  end

  def has_other_pages
    return false unless is_primary
    fetch_other_pages
    !@other_pages.empty?
  end

  def fetch_other_pages
    @other_pages ||= @blog.lord.other_blogs.map {|b| ObjectView.wrap b, @extra}
  end

  def define
    Proc.new do |str|
      @variables = self.class.parse_custom_vars(str)

      if @blog.template_conf.kind_of? Hash
        merge_custom_vars(normalize_variables(@blog.template_conf))
      end
      # `method_missing' rocks but we have to fall back to singleton method for now.
      # See: https://github.com/defunkt/mustache/issues#issue/88
      #
      # Update:
      # Okay now a new release (0.99.3) of mustache solved that issue now
      @variables.each do |type, values|
        values.each do |name, hash|
          self.define_singleton_method "#{type}_#{name}", do
            hash['value']
          end
        end
      end
      ''
    end
  end

  def variables
    @variables
  end

  def post_single
    @extra[:post_single]
  end

  # Ad hoc inline template since we'd make this open to template authors
  def pagination
    p = @extra[:pagination]
    return nil if (!p) || p[:total_pages] == 1
    current_page = p[:page]
    total_pages = p[:total_pages]
    return [
      :current_page => current_page,
      :total_pages => total_pages,
      :prev_page => (current_page > 1 ? "/page/#{current_page - 1}" : nil),
      :next_page => (current_page >= total_pages ? nil : "/page/#{current_page + 1}"),
    ]
  end

  def follow_tag
    widget = @extra[:controller].render_to_string partial: 'blogs/follow_toggle', locals: {blog: @blog}
    (load_js + widget).html_safe
  end

  def apply_tag
    return false unless @blog.applied? @extra[:current_user]
    apply_link = @extra[:controller].editors_new_path
    Proc.new do |str|
      "<a class='btn_apply' href='#{apply_link}' title='申请加入'>#{str}</a>".html_safe
    end
  end

  def control_buttons
    follow_widget = @extra[:controller].render_to_string partial: 'blogs/follow_toggle', locals: {blog: @blog}
    apply_link = @extra[:controller].editors_new_path
    apply_widget = if @blog.applied? @extra[:current_user]
                    "<a class='btn_apply' href='#{apply_link}'>申请加入</a>"
                   else "" end

    <<CODE.html_safe
#{load_js}
<script>document.getElement("head").grab(new Element("link", {
  rel: "stylesheet"
, href: "/stylesheets/control_buttons.css"
}))</script>
<div class='commands'>
  <a class='back_to_home' href='#{home_url}'>回我的主页</a>
  #{follow_widget}
  #{apply_widget}
</div>
CODE
  end

  EXTRACTOR = BlogView.new(Blog.new)
  EXTRACTOR.define_singleton_method :respond_to? do |name|
    name == :define
  end
  EXTRACTOR.define_singleton_method :blog= do |b|
    @blog = b
  end

  private

  def normalize_variables(conf)
    VALUE_PARSERS.each do |type, parser|
      next unless conf.has_key? type
      conf[type].each do |name, var|
        var['value'] = parser.call(var['value'])
      end
    end
    conf
  end

  def merge_custom_vars(hash)
    VALUE_PARSERS.each_key do |type|
      next unless hash.has_key? type
      var_set = @variables[type]
      new_var_set = hash[type]
      var_set.each do |name, v|
        v['default_value'] = v['value']
        v['value'] = new_var_set[name]['value'] if new_var_set.has_key? name
      end
    end
  end
end

Dir[Rails.root.join('lib/object_view/*.rb')].each {|f| require f}

class String
  def respond_to?(name, *args)
    return false if name == :constantize
    super(name, *args)
  end
end
