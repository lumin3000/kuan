module TagStripper
  require 'nokogiri'

  def self.filter(html_str)
    return '' if html_str.blank?
    Nokogiri::HTML.fragment(html_str).inner_text
  end
end
