require 'crawl/core'
require 'crawl/down_img'
require 'nokogiri'

namespace :spider do
  desc "Fetch articles from enabled providers"
  task :crawl => :environment do
    spider=Crawl::Core.new
    spider.crawl    
  end
  
  desc "analyze archive, including save images to local and select one as thumbnail"
  task :downimg => :environment do
    Crawl::DownImg.new.crawl
  end
  
end
