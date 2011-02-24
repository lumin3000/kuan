class Video < Post

  field :external
  field :player
  field :title
  field :desc

  validates_presence_of :player
  attr_accessible :external, :player, :desc, :title, :url

  def url=(url)
    # Stubbed
    type = Video.infer_url_type url
    return if type.nil?
    self.send "#{type}=", url

    # here goes fetching!
    # if type == :external
    #   request = open url
    #   player_url = Video.extract_player request
    # end
  end

  class << self
    def extract_player(html)
      
    end

    def infer_url_type(url)
      case url
        when /\.swf$/
          :player
        when /^http:\/\//
          :external
        else
          nil
        end
    end
  end
end
