require 'net/http'
require 'nokogiri'
require 'anemone/http'

# Crawler crawl sources and save them to db. For different web site there are
# different Crawler derived from AbstractCrawler. Source defines where to find
# content, while Crawler defines how to fetch content. Each source knows which
# Crawler should be used to crawl content.
module Crawler
  class Crawler

    def initialize(source)
      @http=Anemone::HTTP.new()
      @source=source
      @analyzer=source.analyzer
      @pages=[]
      @link_queue=Queue.new
    end

    def fetch_pages
      @source.entrances.each do |url|
        page=@http.fetch_pages(url)
        links=analyzer
      end
    end

    def fetch_links(entrances)
      link_queue=Queue.new
      fetch_pages.each do |page|
        page.links.each { |link| link_queue << link if  }
      end

      http=Anemone::HTTP.new
      entrances.each do |url|
        page=http.fetch_page(url)
        next if (yield page,link_queue if block_given?)

        
        # source defines from where(html elements or xpath of elements) to fetch links
        # And how to filter(using regexp) links that useful
      end
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
  end

end
