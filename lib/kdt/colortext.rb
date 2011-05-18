# -*- coding: utf-8 -*-
#实现宽岛体－彩色文字功能
#用户输入任意文字，可转换成一定格式的指定彩色文字图片
#文字中需要标注彩色的部分，用#做为分隔符

require 'singleton'

class ColorText
  include Singleton

  LINE_LENGTH = 12
  COLORS = %w[blue yellow red green]

  def initialize
    @file_dir = %(#{Rails.root.to_s}/tmp/kdts/)
    @filename_base = %(#{Process.pid}_)
    @color_stick = ""
  end

  def generate(str)
    require 'chinese/width'
    str = Width.instance.half2full str, ['#']
    line_count = 1
    files = wrap_lines(str).map do |line|
      convert line, line_count
      line_count += 1
    end
    #montage files
  end

  private

  def wrap_lines(str)
    str.lines.reduce([]) do |lines, l|
      l.chomp!
      sep_offsets = []
      l.chars.each_with_index {|c, i| sep_offsets << i if c == '#'}
      l.delete! '#'
      if l.length <= LINE_LENGTH
        sep_offsets.each {|i| l.insert i, '#'}
        lines << l
      else
        line_counter = ins_counter = ins_offset = 0
        l.scan(/.{1,#{LINE_LENGTH}}/) do |m|
          ins_offset = ins_counter
          sep_offsets.each do |i|
            if (line_counter*LINE_LENGTH...(line_counter+1)*LINE_LENGTH).cover? i
              m.insert i - line_counter*LINE_LENGTH - ins_offset, '#'
              ins_counter += 1
            end
          end
          lines << m
          line_counter += 1
        end
      end
      lines
    end
  end

  def convert(line)
    command = text.split('#').reduce("convert") do |c, token|
      color = color_flag ? "yellow" : "black"
      color_flag = !color_flag
      c += %( -fill #{color} -font fzxy.ttf -pointsize 48 label:#{token})
    end + %( +append -size 500 -gravity center o.png)
    sub = Subexec.run(command)
  end

  def montage(files)
  end
end
