require 'crawl/core'
require 'nokogiri'

namespace :spider do
  desc "Fetch articles from enabled providers"
  task :crawl => :environment do
    spider=Crawl::Core.new
    spider.crawl    
  end
end
