# -*- coding: utf-8 -*-
require 'uri'
require 'open-uri'

class Moving
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :from_uri
  field :to_uri
  field :trans_cur, :type => Integer, :default => 0
  referenced_in :user

  attr_accessible :user, :from_uri, :to_uri

  validate do |m|
    begin
      open m.from_uri {}
    rescue Exception => e
      errors.add(:base, "请输入有效地址") if e.message != "403 "
    end
  end
  validate do |m|
    b = Blog.where(:uri => m.to_uri).first
    errors.add(:exist, "目标地址已被占用，请输入新的目标地址") unless m.user.own? b
  end
  validates_presence_of :from_uri, :to_uri

  def save
    return unless Moving.where(:from_uri => from_uri, :to_uri => to_uri).empty?

    blog = Blog.where(:uri => to_uri).first
    super unless blog.nil? 
    
    blog = Blog.new(:title => to_uri, :uri => to_uri)
    return errors.add(:exist, "请使用有效的新目标地址") unless blog.save
    user.follow! blog, "founder"
    super 
  end

  def from_uri= (from) 
    return if from.blank?
    from = "http://#{from}" if from !~ /^http:\/\//
    from = "#{from}.kuantu.com" if from !~ /\.kuantu\.com$/
    super from
  end

  def to_uri= (to)
    m = /^http:\/\/([a-z0-9]+)\.kuantu\.com$/.match to
    m.nil? ? super(to) : super(m[1])
  end

  def update_trans_cur(trans_cur)
    self.update_attributes(:trans_cur => trans_cur)
  end

end
