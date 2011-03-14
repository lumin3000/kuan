# -*- coding: utf-8 -*-
class Tag

  class << self
    def trans(tags)
      tags = tags.strip.split(/\s*[,，\n]+\s*/) if tags.kind_of? String
      tags.uniq.reject {|t| invalid? t }
    end

    def invalid?(t)
      t.include? ',' or t.include? '，' or t.include? "\n" or t.blank?
    end
  end

end
