require 'crawl/sources'
require 'crawl/http'
require 'crawl/analyser'
require 'thread'
require 'net/http'
require 'app/models/archive'


module Crawl
  
  
  class Core
    def initialize()
      @http=Crawl::HTTP.new()
      @source=Crawl::Source.enabled
      #@pages=[]
      @link_queue=Queue.new
      #@img_download_queue=Queue.new
      @workers=[]
      #@img_workers=[]
    end

    def crawl
      # Fork some workers
      3.times do
        @workers << Thread.new{ Worker.new(@link_queue,@img_download_queue).run}
      end

      @source.each do |sou|
        log_file=File.expand_path("#{RAILS_ROOT}/log/#{sou[:name]}.log",__FILE__)
        if File.exists?(log_file)
          line=File.open(log_file,'r'){|f| f.readline}
          last_crawled_at=Time.parse(line) rescue (Time.now-3.day)
          #next if last_crawled_at+8.hour>Time.now
        end
        analyser=Object.const_get(sou[:analyser]).new(sou)
        sou[:entrances].each do |entr|
          entr=entr.is_a?(URI) ? entr : URI(entr)
          # get web page of each place
          page=@http.fetch_page(entr,sou[:charset])
          if page.error
            puts "Can't enter source entrance!!! => #{e.message}"
            next
          end
          # get useful links in the web page
          analyser.extract_links(page).each { |link| @link_queue << [link,analyser] }
        end
        File.open(log_file,'w'){|f| f.puts Time.now}
      end
      @workers.size.times {@link_queue<<:END} 
      @workers.each { |th| th.join }
      #@img_workers.each { |th| th.join }
    end

  end
  
  class Worker
    def initialize(link_queue,img_download_queue)
      @queue=link_queue
      @img_download_queue=img_download_queue
      @http=Crawl::HTTP.new()
    end
    
    def run
      loop do
        link,analyser=@queue.deq
        break if link==:END
        puts "Fetch page => #{link.to_s}"
        # fetch page
        page=@http.fetch_page(link,analyser.source[:charset])
        if page.error
          puts "Error fetch page => #{e.message}"
          next
        end
        #puts "HTTP-#{page.code}|| #{page.code.class}"
        next if page.code!=200
        # get real content of the archive
        ok,remark,content_node_set=analyser.extract_content(page)
        if !ok
          puts "analyse failed => #{remark}"
          next
        end
        # puts h[:title]
        # puts h[:pub_date]
        # puts h[:uid]
        # puts h[:content]
        begin
          archive=Archive.new(remark)
          archive.save
          puts "Saved archive to DB"
          #@img_download_queue<<archive
        rescue Mysql2::Error => me
          puts me.message
          next
        rescue Exception => e
          puts "Unknown Exception:#{e.message}"
          puts link
          puts e.backtrace
        end
      end
    end
  end
  

end
