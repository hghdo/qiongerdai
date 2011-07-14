# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

cats=Category.create([
    {:title => '数码',:alias => 'digital'},
    {:title => '美人',:alias => 'beauty'},
    {:title => '游玩',:alias => 'travel'},
    {:title => '读书',:alias => 'book'},
  ])

#Provider.create({
#    :title => 'FashionGuide blog',:url => 'http://blog.fashionguide.com.tw/',
#    :description => 'FashionGuide blog',:category => cats[1],
#    :encoding => 'big5',
#    :url_filter => 'blog\.fashionguide\.com\.tw\/BlogD\.asp',
#    :content_xpath => "//div[@id='blogcontent'][1]",
#    :format => 'html',
#    :enabled => false,
#
#  })
#
#
#Provider.create({
#    :title => 'ifanr 拇指资讯小众讨论',:url => 'http://www.ifanr.com/feed',
#    :description => 'ifanr 拇指资讯小众讨论',:category => cats[0],
#    #:encoding => 'utf-8',
#    #:url_filter => 'blog\.fashionguide\.com\.tw\/BlogD\.asp',
#    #:content_xpath => "//div[@id='blogcontent'][1]",
#    :format => 'rss',
#    :enabled => false,
#
#  })
