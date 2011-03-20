# -*- coding: utf-8 -*-
class Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  field :tag
  index :tag
  field :tagged_count, :type => Integer, :default => 0
  index :tagged_count
  field :activity, :type => Hash, :default => {}
  field :new, :type => Boolean, :default => false

  scope :hottest, desc(:tagged_count).limit(30)

  validates_presence_of :tag

  class << self
    def trans(tags)
      tags = tags.strip.split(/\s*[,，\n]+\s*/) if tags.kind_of? String
      tags.uniq.reject {|t| invalid? t }
    end

    def invalid?(t)
      t.include? ',' or t.include? '，' or t.include? "\n" or t.blank?
    end

    def find_by_tag(t)
      where(:tag => t).first
    end

    def accumulate(tag_str, count, date_str)
      tag = find_by_tag tag_str
      create(:tag => tag_str,
             :tagged_count => count,
             :activity => {date_str => count}) and return if tag.nil?
      tag.tagged_count += count
      tag.activity[date_str] ||= count
      tag.save
    end

    def hot_tag_posts
      hottest.reduce({}) do |posts, tag|
        p = Post.tagged(tag.tag).pics_and_text.limit(30).sample
        posts[tag.tag] = p unless p.nil?
        posts
      end
    end

    def set_new_hots(old_hots)
      old_hots.each {|tag| tag.update_attributes(:new => false)}
      (hottest.to_a - old_hots).each { |tag| tag.update_attributes(:new => true)}
    end
  end
end
