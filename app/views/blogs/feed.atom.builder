atom_feed(:language => "zh-CN",
          :schema_date => Time.now.year) do |feed|
  feed.title @blog.title
  feed.subtitle @blog.desc, :type => 'html'
  feed.updated @posts.first.created_at
  feed.logo @blog_url + @blog.icon.url_for(:medium)
  feed.icon @blog_url + @blog.icon.url_for(:small)

  @posts.each do |post|
    feed.entry(post, :url => posts_blog_path(post)) do |entry|
      case post.class.to_s
      when "Text"
        entry.title post.title
        entry.content post.content, :type => 'html'
      when "Pics"
        c = post.photos.reduce("") do |sum, photo|
          sum += <<EOF
<div>#{photo.desc}</div>
<div><a href="#{@blog_url + photo.image.url_for(:original)}">
<img src="#{@blog_url + photo.image.url_for(:large)}" /></a></div>
EOF
        end
        c += %(<div>#{post.content}</div>)
        entry.content c, :type => 'html'
      when "Link"
        entry.title post.title
        c = <<EOF
<div><a href="#{post.url}">#{post.url}</a></div>
<div>#{post.content}</div>
EOF
        entry.content c, :type => 'html'
      when "Video"
        c = <<EOF
<div><img src="#{post.thumb}" /></div>
<div>#{post.content}</div>
EOF
        entry.content c, :type => 'html'
      when "Audio"
        entry.title post.song_name + '-' + post.artist_name
        c = <<EOF
<div><img src="#{post.album_art}" /></div>
<div>#{post.content}</div>
EOF
        entry.content c, :type => 'html'
      end

      entry.author do |author|
        author.name post.author.name
      end
    end
  end
end
