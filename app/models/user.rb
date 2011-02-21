class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name
  field :email
  field :salt
  field :encrypted_password
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation

  validates :name, :presence => true,
  :length => {:maximum => 10}

  validates :email, :presence => true,
  :format => {:with => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i},
  :uniqueness => {:case_sensitive => false}

  validates :password, :presence => true,
  :confirmation => true,
  :length => {:within => 5..10}

  before_save :encrypt_password
  before_save :email_downcase

  def has_password?(password)
    encrypted_password == encrypt(password)
  end

  class << self
    def authenticate(email, password)
      user = where(:email => email).first
      user && user.has_password?(password) ? user : nil
    end
  end
  
  private

  def email_downcase
    self.email.downcase!
  end

  def encrypt_password
    self.salt = make_salt
    self.encrypted_password = encrypt password
  end

  def make_salt
    secure "#{Time.now.utc}--#{password}"
  end

  def encrypt(password)
    secure "#{salt}--#{password}"
  end
  
  def secure(string)
    Digest::SHA2.hexdigest string
  end
end
