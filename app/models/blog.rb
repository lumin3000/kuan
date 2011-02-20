class Blog < Post
  field :title
  field :content
  
  attr_accessible :title, :content
end
