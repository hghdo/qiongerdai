require 'net/http'
require 'nokogiri'

class AbstractCrawler

  def fetch_links
    @entrances.each do |url|
      url = URI(url) unless url.is_a?(URI)
      http=connection(url)
      full_path = url.query.nil? ? url.path : "#{url.path}?#{url.query}"
      req = Net::HTTP::Get.new(full_path, opts)
      response=http.request(req,opts)
      @doc = Nokogiri::HTML(response.body,nil,@charset) if @body && html? rescue nil
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
