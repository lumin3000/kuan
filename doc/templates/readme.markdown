## 语法

### 填充变量

    {{title}} -- This is my blog!
    {{  title }} white space is okay~

### 进入/退出section

进入section之后可以填充相应数据对象（post, user, etc.）的属性

下面例子中，posts是一个循环section, section中的模板代码会应用于每一条post。而text是条件判断section，类型为"文字"的帖子才会进入该section并使用其中的代码。

下层section中可以访问到上层中的字段/section

    <h1>{{title}}</h1> -- Title for blog
    {{#posts}}

      {{#post_single}}
        似乎只有一个帖子
        <!-- 已经进入posts section，但该section属于顶级作用域，仍可访问 -->
      {{/post_single}}

      {{#text}}
        <h2>{{title}}</h2> <!-- Title of text post -->
        {{content}} <!-- Content of text post -->
        发帖时间：{{create_date}}
      {{/text}}

    {{/posts}}


## 字段们

### 顶级作用域

#### 字段

* title 博客标题
* url 博客首页（亦即帖子列表页）
* desc 页面描述
* meta_desc 经HTML转义并剔除标签的页面描述
* icon_180 180x180博客图标链接
* icon_60 60x60博客图标链接
* icon_24 24x24博客图标链接

#### section

* followings 页面拥有者所关注的页面
* has_following 仅用户主页面可以进入
* define 定义可以由模板使用者自行调整的变量，详见define section
* posts 循环展示每个帖子，帖子单页与列表页皆可用
* post_single 若当前页面为帖子单页会进入该section
* post_index 若当前页面为帖子列表页会进入该section
* pagination 进入分页代码section，若帖子不足一页或不在列表页上则不会进入

### posts section

posts section中的字段是各类帖子共享的

#### 字段

* type 帖子类型，为每种帖子单独写class时可用
* url 帖子单页链接
* comments_count 帖子回复数量
* load_comments 加载回复代码

#### section

* author 进入作者section，可访问帖子作者信息
* create_date 帖子的发表时间，进入Time Section访问发帖时间信息
* repost_tag 生成一个`<a>`标签用于转帖；section中间的内容会放在`<a>`标签下
* fave_tag 生成一个`<a>`标签用于喜欢该帖子；section中间的内容会放在`<a>`标签下
* is_repost 如果是转帖发布可以进入该section
* parent 如果是转帖发布可以进入一个Blog Section访问转帖来源页面的信息

### text section

posts section下可用，"文字"类型的帖子可进入该section

#### 字段

* title 标题内容，可能为空
* content 正文内容，可能为空

### photo\_single/photo\_set section

posts section下可用，"图片"类型的帖子如果只有一张图片可进入photo_single section，若多于一张则可进入photo_set section。

#### 字段

* content 描述内容，可能为空

#### section

* photos 进入photos section循环访问每张图片信息(即使只有一张)

### photos section

photo_single/photo_set section下可用

#### 字段

* desc 图片描述
* image_original 原始图片链接
* image_500 图片链接，宽度不超过500px
* image_400 图片链接，宽度不超过400px
* image_250 图片链接，宽度不超过250px
* image_100 图片链接，宽度不超过100px
* image_75 75x75图片链接
* image_60 60x60图片链接

### link section

posts section下可用，"链接"类型的帖子可进入该section

#### 字段

* title 标题内容，可能为空
* shared_url 推荐的链接URL
* content 描述内容，可能为空

### video section

posts section下可用，"视频"类型的帖子可进入该section

#### 字段

* video_code_500 大坨视频代码，点击展开后宽度为500px
* content 描述内容，可能为空

### user section

帖子中的author section属user section
未来可能开放页面管理员／成员等

* name 用户名
* user_url 用户主页面链接
* avatar_180 180x180头像图片链接
* avatar_96 96x96头像图片链接
* avatar_64 64x64头像图片链接
* avatar_60 60x60头像图片链接
* avatar_48 48x48头像图片链接
* avatar_40 40x40头像图片链接
* avatar_30 30x30头像图片链接
* avatar_24 24x24头像图片链接
* avatar_16 16x16头像图片链接

### Blog section

转帖来源页面的信息

* title 页面标题
* url 页面链接
* icon_180 180x180页面图标链接
* icon_96 96x96页面图标链接
* icon_64 64x64页面图标链接
* icon_60 60x60页面图标链接
* icon_48 48x48页面图标链接
* icon_40 40x40页面图标链接
* icon_30 30x30页面图标链接
* icon_24 24x24页面图标链接
* icon_16 16x16页面图标链接

### Time Section
