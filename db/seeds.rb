# encoding: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
Tweet.create content: "foooo"
Tweet.create content: "很长很长的中文tweet一枚很长很长的中文tweet一很长很长的中文tweet一枚枚很长很长的中文tweet一枚"

Link.create url: "http://g.cn", title: "Google", content: "This is it!"

Blog.create({
  title: "Context Switch",
  content: <<EOF,
  Makefile的缩进必须使用tab而非空格
  Lua的数组index要从1开始而不是0
  JS的in操作符(包括key in obj与for...in)会沿原型链向上查找, Python就没这么多事
  shell里一群$*之类的符号让人们打印更多的cheat sheet
   
  手册? 文档? Session? Callback? 重写? 重构?
  看似不难统一的概念, 总有人自学时喜欢另辟蹊径
  能把DOM记成CGI, 为之奈何.
   
  找出一个人人都能自然接受的软件架构就那么难?
  Counter-intuitive的东西到处都是
  有些设计理念难道不该是built-in的吗
  无论语言特性与API可靠抑或不可靠.
  由此我开始真正敬仰开源项目的维护者.
   
  把你的WebApp换台机器配置上去要少个步骤?
  搭建起完整的开发环境又要多久?
  各种级别的测试能很简单地跑的起来吗?
  有足够的夹具和fake/mock吗?
  整个代码库是Self-contained吗?
   
  我开始能理解为什么总有人在寻找一本在手别无所求的`手册`了
  不需Context Switch的世界是多么美好.
EOF
})
