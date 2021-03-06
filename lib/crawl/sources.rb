module Crawl
  class Source
    def Source.config
      [
        #
        {:name => 'FGBlog',
         :enabled => true,
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
        # http://blog.vogue.com.cn/
        {:name => 'VogueBlog',
         :enabled => true,
         :analyser => 'GeneralAnalyser',
         :entrances => [
           'http://space.vogue.com.cn/',
           'http://space.vogue.com.cn/home.php?mod=space&uid=267005',
           'http://space.vogue.com.cn/home.php?mod=space&uid=426275',
           'http://space.vogue.com.cn/home.php?mod=space&uid=256640',
           'http://space.vogue.com.cn/home.php?mod=space&uid=276286',
            ],
          :archive_patterns => [
            /space\.vogue\.com\.cn\/blog-\d{5,10}-\d{5,10}\.html/,
            # /blog\.vogue\.com\.cn\/\?\d{5,10}\/viewspace-\d{5,10}\.html$/,
            # /blog\.vogue\.com\.cn\/\?uid-\d{5,10}-action-viewspace-itemid-\d{5,10}$/,
            ],
          :unique_id_pattern => /(\d{5,10})\.html/,
          # :unique_id_scan_result_offset => 1,
          :content_path_expression => "//div[@id='blog_article']",
          :pub_date_xpath => "//div[@id='show']/p[@class='xspace-smalltxt']", 
          :pub_date_css => "div#ct>div.mn>div.bm>div.bm_c>div.vw>div.h>p.xg2", 
          :pub_date_method => 'css',
          :pub_date_pattern => /(\d{4}-\d{1,2}-\d{1,2}\s\d{1,2}:\d{1,2})/,
          :charset => 'gbk',
          :max_age => 7, 
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
          :archive_patterns => [/blog\.yoka\.com\/\d{3,7}\/\d{6,8}\.html/],
          :unique_id_pattern => /(\d{6,8})\.html/,
          :content_path_expression => "//div[@class='blogContent']/div[@class='blogCnr']",
          :pub_date_xpath => "//div[@class='blogContent']/dl[@class='blogCtit']/dd/span", 
          :pub_date_css => "div.blogContent>dl.blogCtit>dd>span", 
          :pub_date_pattern => /(\d{4}.+)/,
          :charset => 'utf-8',
          :max_age => 1, 
        }, 
        # 
        { :name => 'rayliForum',
          :enabled => true,
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
          :enabled => true,
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
