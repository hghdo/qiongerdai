module Crawl
  class Source
    def Source.config
      [
        #
        {:name => 'FGBlog',
         :enabled => false,
         :analyser => 'GeneralAnalyser',
         :entrances => [
            "http://blog.fashionguide.com.tw/",
            "http://blog.fashionguide.com.tw/index.asp?TypeNum=2",
            "http://blog.fashionguide.com.tw/index.asp?TypeNum=3",
            "http://blog.fashionguide.com.tw/index.asp?TypeNum=5",
            "http://blog.fashionguide.com.tw/index.asp?TypeNum=19",
            ],
          :archive_patterns => [/blog\.fashionguide\.com\.tw\/BlogD\.asp/,],
          :unique_id_pattern => /Num=(\d{5,})/,
          :content_path_expression => "//div[@id='blogcontent'][1]",
          :pub_date_xpath => "//div[@id='blog']//div[@class='head']/div[@class='time']", 
          :pub_date_css => "div#blog div.head>div.time", 
          :pub_date_pattern => /\d{4}\.\d{1,2}.*/,
          :charset => 'big5',
          :max_age => 3, 
        }, 
        # 
        { :name => 'rayliForum',
          :enabled => true,
          :analyser => 'ForumAnalyser',
          :entrances => [
            "http://bbs.rayli.com.cn/forum-19-1.html",
            "http://bbs.rayli.com.cn/forum-19-2.html",
            "http://bbs.rayli.com.cn/forum-19-3.html",
            ],
          :thread_list_xpath => "//div[@id='threadlist']//form/table/tbody",
          :thread_id_pattern => /_(\d+)/,
          :author_id_url_in_thread_list_xpath => "tr/td[@class='by']/cite/a",
          :author_id_scan_pattern => /uid-(\d+)\.html/,
          :wrote_date_in_thread_list_xpath => "tr/td[@class='by']/em",
          :hit_count_in_thread_list_xpath => "tr/td[@class='num']/em",
          :link_template => "http://bbs.rayli.com.cn/forum-viewthread-tid-#THRID#-page-1-authorid-#AUTHID#.html",        
          :content_path_expression => "//div[@class='t_fsz']",
          :search_content_node_method => 'xpath',
          :pub_date_css => "div.pi>div.pti>div.authi em", 
          :pub_date_pattern => /\s(\d{4}-.+)/,
          #:archive_patterns => [/viewthread\.php\?tid=\d{5,}&page=1&authorid=\d{3,}$/,],
          :unique_id_pattern => /tid-(\d+)-/,
          :charset => 'gbk',
          :max_age => 3,       
          :min_hit => 10, 
          :min_reply => 10, 
          
        }, 
        # 
        { :name => 'sinaForum',
          :enabled => false,
          :analyser => 'ForumAnalyser',
          :entrances => [
            "http://club.eladies.sina.com.cn/forum-2-1.html",
            "http://club.eladies.sina.com.cn/forum-2-2.html",
            "http://club.eladies.sina.com.cn/forum-2-3.html",
            ],
          :archive_patterns => [/viewthread\.php\?tid=\d{5,}&page=1&authorid=\d{3,}$/,],
          :unique_id_pattern => /Num=\d{5,}/,
          :content_path_expression => "div.postmessage",
          :search_content_node_method => 'css',
          :pub_date_xpath => "//div[@id='blog']//div[@class='head']/div[@class='time']", 
          :pub_date_pattern => /\d{4}\.\d{1,2}.*/,
          :charset => 'gbk',
          :max_age => 3, 
          :thread_list_xpath => "//div[@id='threadlist']/form/table/tbody/tr",
          :wrote_dat_in_thread_list_xpath => "td[@class='author']/em",
          :hit_count_in_thread_list_xpath => "td[@class='nums']/em",
          :author_id_url_in_thread_list_xpath => "td[@class='author']/cite/a",
          :author_id_in_thread_list_scan_regexp => '\d+',          
          :min_hit => 100, 
          :min_reply => 10, 
          
          }, 
      ]

    end
    
    def Source.all
      Source.config
    end
    
    def Source.enabled
      Source.all.select {|sou| sou[:enabled]}
    end
    
  end
end
