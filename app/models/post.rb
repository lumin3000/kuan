class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  
  def haml_object_ref
    "post"
  end

  alias type= _type=
  def type
    self._type.downcase
  end

  def self.infer_type(t)
    klass = Object.const_get t.capitalize
    if self.subclasses.include? klass
      klass
    else
      nil
    end
  end

  def self.default_type
    "text"
  end

  # Must stub this out
  def photos(*args)
  end
end
