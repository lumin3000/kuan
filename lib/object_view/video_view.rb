# encoding: utf-8

class VideoView < PostView
  expose_without_escape :@post, :content

  def video
    true
  end

  def video_code_500
    source = @post.site.nil? ? "" : <<SOURCE.html_safe
  <span>
    来自:<a href="#{h @post.url}">#{h @post.site}</a>
  </span>
SOURCE

    <<CODE.html_safe
#{load_js}
<div data-widget="video">
  <div class="video_thumb">
    <a href="#{h @post.player}" class="video_tar_open">
      <img src="#{h @post.thumb}" />
      <div class="video_thumb_play">&nbsp;</div>
    </a>
  </div>
  <div class="video_full">
    <span>
      <a class="video_tar_close" href="###">收起</a>
    </span>
    #{source}
    <div class="video_player"></div>
  </div>
</div>
CODE
  end

  def title
    nil
  end
end
