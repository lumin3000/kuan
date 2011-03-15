# encoding: utf-8

require 'cgi'

module ObjectView
  def self.wrap(obj, extra = {})
    (obj.class.name + "View").constantize.new(obj, extra)
  end

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def respond_to?(method)
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

  def custom_css
    "<style type='text/css'>#{h @blog.custom_css}</style>".html_safe
  end

  def posts
    @posts
  end

  def post_single
    @extra[:post_single]
  end

  def url
    @url_template && @url_template % @blog.uri
  end

  def home_url
    @url_template && @url_template % 'www'
  end

  { 180 => :large,
    60 => :medium,
    24 => :small, }.each do |k, v|
    define_method("icon_#{k}") do
      @blog.icon.url_for(v)
    end
  end

  def define
    Proc.new do |str|
      @variables = self.class.parse_custom_vars(str)

      if @blog.template_conf.kind_of? Hash
        merge_custom_vars(normalize_variables(@blog.template_conf))
      end
      # `method_missing' rocks but we have to fall back to singleton method for now.
      # See: https://github.com/defunkt/mustache/issues#issue/88
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
    return if not @extra[:pagination]
    current_page = @extra[:pagination][:page]
    per_page = @extra[:pagination][:per_page]

    prev_page, cur_page_code = if current_page > 1
      [ "<a class='page_left' href='/page/#{current_page - 1}'>&#8592; 过去的</a>",
        "<div class='page_number'>#{current_page}</div>"
      ]
    else
      ['', '']
    end

    next_page = if (!@posts.empty? && @posts.length >= per_page)
      "<a class='page_right' href='/page/#{current_page + 1}' >以前的 &#8594;</a>"
    else
      ''
    end

    <<TPL.html_safe
<div class="page_control">
  #{prev_page}
  #{cur_page_code}
  #{next_page}
</div>
TPL
  end

  def respond_to?(name)
    return true if name.to_s =~ /^(?:color|bool|text|image)_/
    super
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
