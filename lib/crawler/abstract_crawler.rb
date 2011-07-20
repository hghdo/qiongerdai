require 'net/http'
require 'nokogiri'

# Crawler crawl sources and save them to db. For different web site there are
# different Crawler derived from AbstractCrawler. Source defines where to find
# content, while Crawler defines how to fetch content. Each source knows which
# Crawler should be used to crawl content.
module Crawler
  class AbstractCrawler

    def fetch_links
      @entrances.each do |url|
        url = URI(url) unless url.is_a?(URI)
        http=connection(url)
        full_path = url.query.nil? ? url.path : "#{url.path}?#{url.query}"
        req = Net::HTTP::Get.new(full_path, opts)
        response=http.request(req,opts)
        @doc = Nokogiri::HTML(response.body,nil,@charset) if @body && html? rescue nil
        # source defines from where(html elements or xpath of elements) to fetch links
        # And how to filter(using regexp) links that useful
      end
      url=@entrances
      http=Net::Http.new()
      
    end

    def fetch_content
      # Get web page title
      # Get content
      # Get publish date
      # Save web page doucment to DB
      # download images
    end

    def fetch_imgs
          
    end

    def connection(url)
      
    end
  end

end
