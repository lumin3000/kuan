class Message
  include Mongoid::Document
  field :type
  field :content
  field :unread, type: Boolean, default: true
  field :done, type: Boolean, default: false
  field :ignored, type: Boolean, default: false
  field :sender_id
  referenced_in :blog
  embedded_in :user, :inverse_of => :messages
  scope :unreads, where(unread: true)
  validates :type, :inclusion => {:in => %w[join join_feed follow register]}

  LIMIT = 100
  
  def sender=(sender)
    self.sender_id = sender.id
  end

  def sender
    User.find(sender_id) unless sender_id.nil?
  end

  def read!
    update_attributes unread: false 
  end

  def ignore!
    update_attributes ignored: true
  end

  def doing!
    return if done?
    send type
    update_attributes done: true
  end

  def feed!
    message = Message.new(:sender => user,
                          :blog => blog,
                          :type => type+'_feed') 
    sender.receive_message! message
    message
  end

  def join
    sender.follow! blog, "member" if blog.applied?(sender) and blog.customed?(user)
    #all apply join message for the sender to the blog should be done
    blog.founders.each do |founder|
      m = founder.messages.where(type: "join", blog_id: blog.id).first
      m.update_attributes(done: true) unless m.nil?
    end
  end
end
