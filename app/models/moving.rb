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

  attr_accessible :trans_cur

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
    
    blog = Blog.create(:title => to_uri, :uri => to_uri)
    return errors.add(:exist, "请使用有效的新目标地址") if blog.nil?
    user.follow! blog, "founder"
    super 
  end

  def from_uri= (from_uri)
    return if from_uri.blank?
    from_uri = "http://#{from_uri}" if from_uri !~ /^http:\/\//
    from_uri = "#{from_uri}.kuantu.com" if from_uri !~ /\.kuantu\.com$/
    super from_uri
  end

  def to_uri= (to_uri)
    m = /^http:\/\/([a-z0-9]+)\.kuantu\.com$/.match to_uri
    m.nil? ? super(to_uri) : super(m[1])
  end

end
