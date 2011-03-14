# encoding: utf-8

class Template
  include Mongoid::Document

  field :name
  field :html
  referenced_in :author, :class_name => 'User'
  referenced_in :thumbnail, :class_name => 'Image'

  DEFAULT_TPL = File.read(Rails.root + 'lib' + 'default_blog_template.mustache')
  DEFAULT = Template.new :html => DEFAULT_TPL, :name => '默认模板',
    :thumbnail => Image.last, :author => User.first
  DEFAULT.define_singleton_method :id, do
    nil
  end
end
