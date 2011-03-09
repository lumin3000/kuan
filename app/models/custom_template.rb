class CustomTemplate
  include Mongoid::Document

  field :name
  field :html
  referenced_in :author, :class_name => 'User'
  referenced_in :thumbnail, :class_name => 'Image'

  DEFAULT_TPL = File.read(Rails.root + 'lib' + 'default_blog_template.mustache')
  DEFAULT = CustomTemplate.new :html => DEFAULT_TPL
end
