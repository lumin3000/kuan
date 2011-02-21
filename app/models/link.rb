class Link < Post
  field :url
  field :title
  field :content

  attr_accessible :url, :title, :content

  validates_presence_of :url
end
