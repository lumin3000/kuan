# -*- coding: utf-8 -*-
# 本类实现ascii字符的半角和全角转换功能

require 'singleton'

class Width
  include Singleton

  def half2full(str, excludes=[])
    str.codepoints.map do |b|
      case b
      when 32
        12288
      when 33...256
        excludes.include?(b.chr) ? b : b+65248
      else
        b
      end.chr
    end.join
  end
end
