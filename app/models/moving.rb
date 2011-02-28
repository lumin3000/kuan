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

  attr_accessible :user, :from_uri, :to_uri, :trans_cur

  validates_presence_of :from_uri, :to_uri

  def from_uri_valid?
    begin
      open from_uri
    rescue Exception => e
      if e.message != "403 "
        errors.add(:base, "此地址已经无效")
        return false
      end
    end
    true
  end

  def save
    return false unless from_uri_valid?

    if not Moving.where(:from_uri => from_uri, :to_uri => to_uri).empty?
      return (trans_cur > 0) ? super : true
    end

    blog = Blog.where(:uri => to_uri).first
    if not blog.nil?
      if not user.own? blog
        errors.add(:exist, "目标地址已被占用，请输入新的目标地址")
        return false
      else
        return super
      end
    end
    
    blog = Blog.new(:title => to_uri, :uri => to_uri)
    if not blog.save
      errors.add(:exist, "请使用有效的新目标地址")
      false
    else
      user.follow! blog, "founder"
      super 
    end
  end

  def from_uri= (from) 
    return if from.blank?
    from = "http://#{from}" if from !~ /^http:\/\//
    from = "#{from}.kuantu.com" if from !~ /\.kuantu\.com\/?$/
    super from
  end

  def to_uri= (to)
    m = /^http:\/\/([a-z0-9]+)\.kuantu\.com\/?$/.match to
    m.nil? ? super(to) : super(m[1])
  end

end
