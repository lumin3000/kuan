class Tweet < Post
  include Mongoid::Document

  field :content
end
