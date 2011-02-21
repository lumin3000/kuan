class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  alias type _type
  alias type= _type=

  def self.infer_type(t)
    klass = Object.const_get t.capitalize
    if self.subclasses.include? klass
      klass
    else
      nil
    end
  end
end
