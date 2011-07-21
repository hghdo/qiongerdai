# Source to crawl
module Source
  class FGBlogSource

    def name
      "FGBlog"     
    end

    def entrances
      [
        "http://blog.fashionguide.com.tw/",
        "http://blog.fashionguide.com.tw/index.asp?TypeNum=2",
        "http://blog.fashionguide.com.tw/index.asp?TypeNum=3",
        "http://blog.fashionguide.com.tw/index.asp?TypeNum=5",
        "http://blog.fashionguide.com.tw/index.asp?TypeNum=19",
      ]
    end

    def fetch_links
      
    end

    def link_filters
      [
        "blog\.fashionguide\.com\.tw\/BlogD\.asp",
      ]
    end

    def unique_id_pattern
      'Num=\d{5,}'
    end

  end
end
