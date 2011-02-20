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
