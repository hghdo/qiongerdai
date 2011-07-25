require 'crawl/sources'
require 'crawl/http'
require 'crawl/analyser'
require 'thread'


module Crawl
  class Core
    
    def initialize()
      @http=Crawl::HTTP.new()
      @source=Crawl::Source.enabled
      @pages=[]
      @link_queue=Queue.new
      @workers=[]
    end

    def crawl
      # Fork some workers
      1.times do
        @workers << Thread.new{ Worker.new(@link_queue).run}
      end
      
      @source.each do |sou|
        analyser=Object.const_get(sou[:analyser]).new(sou)
        sou[:entrances].each do |entr|
          puts "Find links in => #{entr}"
          entr=entr.is_a?(URI) ? entr : URI(entr)
          
          # get web page of each place
          page=@http.fetch_page(entr,sou[:charset])
          # get useful links in the web page
          analyser.extract_links(page).each { |link| @link_queue << [link,analyser] }
        end
      end
      
      @workers.each { |th| th.join }
    end

  end
  
  class Worker
    def initialize(link_queue)
      @queue=link_queue
      @http=Crawl::HTTP.new()
    end
    
    def run
      loop do
        link,analyser=@queue.deq
        puts "Fetch archive page => #{link.to_s}"
        # fetch page
        page=@http.fetch_page(link,analyser.source[:charset])
        if page.error
          puts "Error fetch page => #{e.message}"
          next
        end
        puts "HTTP-#{page.code}"
        next if page.code!='200'
        # get real content of the archive
        txt=analyser.extract_content(page)
        puts "OK"
      end
    end
  end
end