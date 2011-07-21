module Crawler
  class Source
    def Source.config
      {:name => FGBlog,
       :analyser => 'GeneralAnalyser',
       :entrances => [
          "http://blog.fashionguide.com.tw/",
          "http://blog.fashionguide.com.tw/index.asp?TypeNum=2",
          "http://blog.fashionguide.com.tw/index.asp?TypeNum=3",
          "http://blog.fashionguide.com.tw/index.asp?TypeNum=5",
          "http://blog.fashionguide.com.tw/index.asp?TypeNum=19",
          ],
        :link_pattern => ["blog\.fashionguide\.com\.tw\/BlogD\.asp",],
        :unique_id_pattern => 'Num=\d{5,}',
        :charset => 'big5',
      } 


    end
  end
end
