class Audio < Post
  include Mongoid::Document
  field :song_id
  field :album_art
  field :song_name
  field :artist_name
  field :content

  attr_accessible :song_id, :album_art, :content, :song_name, :artist_name

  before_validation :sanitize_content
  validates_presence_of :song_id
end
