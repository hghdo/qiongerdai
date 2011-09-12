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
          :pub_date_css => "div#wrapper>div#blog>div#blogcontent div.head>div.time", 
          :pub_date_pattern => /\s(\d{4}.+)/,
          :charset => 'big5',
          :max_age => 1, 
        }, 
        #
        {:name => 'YokaBlog',
         :enabled => true,
         :analyser => 'GeneralAnalyser',
         :entrances => [
            "http://blog.yoka.com/",
            "http://blog.yoka.com/html/dpg/index.shtml",
            "http://space.yoka.com/blog/ipage/star_article.php?type=0&page=1&page_size=50", # new blog file list
            "http://blog.yoka.com/html/brand/index.shtml",
            "http://blog.yoka.com/html/fashion/index.shtml"
            ],
          :archive_patterns => [/blog\.yoka\.com\/\d{3,7}\/\d{6,7}\.html/],
          :unique_id_pattern => /(\d{6,7})\.html/,
          :content_path_expression => "//div[@class='blogContent']/div[@class='blogCnr']",
          :pub_date_xpath => "//div[@class='blogContent']/dl[@class='blogCtit']/dd/span", 
          :pub_date_css => "div.blogContent>dl.blogCtit>dd>span", 
          :pub_date_pattern => /(\d{4}.+)/,
          :charset => 'utf-8',
          :max_age => 3, 
        }, 
        # 
        { :name => 'rayliForum',
          :enabled => false,
          :analyser => 'ForumAnalyser',
          :entrances => [
            "http://bbs.rayli.com.cn/forum-19-1.html",
            "http://bbs.rayli.com.cn/forum-19-2.html",
            #"http://bbs.rayli.com.cn/forum-19-3.html",
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
          :min_hit => 70, 
          :min_reply => 10, 
          
        }, 
        # 
        { :name => 'sinaForum',
          :enabled => false,
          :analyser => 'ForumAnalyser',
          :entrances => [
            "http://club.eladies.sina.com.cn/forum-2-1.html",
            "http://club.eladies.sina.com.cn/forum-2-2.html",
            ],
          :thread_list_xpath => "//table[@id='forum_2']/tbody",
          :thread_id_pattern => /_(\d+)/,
          :author_id_url_in_thread_list_xpath => "tr/td[@class='author']/cite/a",
          :author_id_scan_pattern => /uid=(\d+)/,
          :wrote_date_in_thread_list_xpath => "tr/td[@class='author']/em",
          :hit_count_in_thread_list_xpath => "tr/td[@class='nums']/em",
          :link_template => "http://club.eladies.sina.com.cn/viewthread.php?tid=#THRID#&page=1&authorid=#AUTHID#",        
          :content_path_expression => "div.mybbs_cont > div.cont",
          :search_content_node_method => 'css',
          :pub_date_css => "div.myInfo_up > font", 
          :pub_date_pattern => /(\d{4}-.+)/,
          :unique_id_pattern => /tid=(\d+)&/,
          :charset => 'gb2312',
          :max_age => 2,       
          :min_hit => 100, 
          :min_reply => 10,
          }, 
          
          #
          {
            :name => 'yokaBlog',
            :enabled => false, 
            :analyser => 'GeneralAnalyser',
            :entrances => ["http://blog.yoka.com/"], 

          }
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
