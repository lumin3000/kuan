# -*- coding: utf-8 -*-
require 'spec_helper'

describe Video do
  before :each do
    @video = Video.new
    @blog = Factory :blog, :uri => Factory.next(:uri)
    @author = Factory :user, :email => Factory.next(:email)
    @author.follow! @blog, 'lord'
    @video.author = @author
    @video.blog = @blog
  end

  it "should reject the invalid url" do
    @video.url = "invalid"
    @video.should_not be_valid
    @video.errors.should_not be_blank
  end

  it "should accept the url ended with .swf" do
    @video.url = %(http://you.video.sina.com.cn/api/sinawebApi/outplayrefer.php/vid=46843841_1_OxjgTndpWTLK+l1lHz2stqkM7KQNt6nknynt71+iJAxfUQiIYIrfO4kK5C/eBMxK9W0/s.swf)
    @video.should be_valid
  end

  it "should accept the shared html having embed tag" do
    @video.url = <<-eohtml
      <div><object id="ssss" width="480" height="370" >
        <param name="allowScriptAccess" value="always" />
        <embed pluginspage="http://www.macromedia.com/go/getflashplayer"
                 src="http://you.video.sina.com.cn/api/sinawebApi/outplayrefer.php/vid=46843841_1_OxjgTndpWTLK+l1lHz2stqkM7KQNt6nknynt71+iJAxfUQiIYIrfO4kK5C/eBMxK9W0/s.swf"
                 type="application/x-shockwave-flash" name="ssss" allowFullScreen="true"
                 allowScriptAccess="always" width="480" height="370">
        </embed>
      </object></div>
    eohtml
    @video.should be_valid
  end

  it "should accept the youku url" do
    @video.url = %(http://v.youku.com/v_show/id_XMjQ2MzMwMzE2.html)
    @video.should be_valid
    @video.player.should == "http://player.youku.com/player.php/sid/XMjQ2MzMwMzE2/v.swf"
    @video.content.should == "【拍客】重庆建两艘过亿豪华游轮-可停靠直升机 - 视频 - 优酷视频 - 在线观看"
    @video.thumb.should == "http://g3.ykimg.com/0100641F464D669C0E9D55025646FE22F0A27C-5E6A-A637-8792-73F22049C63C"
    @video.url.should == %(http://v.youku.com/v_show/id_XMjQ2MzMwMzE2.html)
    @video.site.should_not be_blank
  end

  it "should accept the tudou url" do
    @video.url = %(http://www.tudou.com/programs/view/iGHZOTo0qjU/)
    @video.should be_valid
    @video.player.should == %(http://www.tudou.com/v/iGHZOTo0qjU/v.swf)
    @video.content.should == "新西兰强震16名中国留学生被埋_在线视频观看_土豆网视频 新西兰 克赖斯特彻奇 中国留学生 国际救援队 抗震救灾"
    @video.thumb.should == "http://i01.img.tudou.com/data/imgs/i/073/046/094/p.jpg"
  end

  it "should accept the ku6 url" do
    @video.url = %(http://v.ku6.com/special/show_3306516/-FrZYUaTNSfGhlmG.html)
    @video.should be_valid
    @video.player.should == %(http://player.ku6.com/refer/-FrZYUaTNSfGhlmG/v.swf)
    @video.content.should == "山寨新闻:艺考穿三点,是考试还是选美?(11.02.25) 在线观看 - 酷6视频专辑"
    @video.thumb.should == "http://i0.ku6img.com/encode/picpath/2011/2/24/19/1301645197570_98683_98683/2.jpg"
  end
end
