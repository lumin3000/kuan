class AudioView < PostView
  expose_without_escape :@post, :content
  expose :@post, :song_name, :artist_name, :album_name
  expose_by_dict :@post, :album_art => :album_art_100

  def audio
    true
  end

  def album_art_55
    h @post.album_art.sub(/_1\.jpg$/, '_3.jpg')
  end

  def player_code
    build_player_code @post.flash_url
  end

  def player_code_autoplay
    build_player_code @post.flash_url_autoplay
  end

  def build_player_code(url)
    <<CODE.html_safe
<embed src="#{url}" wmode="transparent" width=257 height=33
  type="application/x-shockwave-flash">
</embed>
CODE
  end
  private :build_player_code
end
