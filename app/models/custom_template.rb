class CustomTemplate
  include Mongoid::Document

  field :html

  DEFAULT_TPL = File.read(Rails.root + 'lib' + 'default_blog_template.mustache')
  DEFAULT = CustomTemplate.new :html => DEFAULT_TPL
end
