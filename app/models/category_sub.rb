class CategorySub
  include Mongoid::Document
  include Mongoid::Timestamps

  field :new, :type => Boolean, :default => false
  field :top, :type => Boolean, :default => false
  field :order, :type => Integer, :default => 0
  field :image, :type => String

  referenced_in :blog
  embedded_in :category, :inverse_of => :category_subs

  attr_accessible :new, :top, :order, :image, :blog, :blog_id
end
