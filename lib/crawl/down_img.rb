require 'net/http'
require 'thread'

module Crawl
  class DownImg

    def initialize()
      @queue=Queue.new
      @img_workers=[]
    end

    def crawl
      1.times do
        @img_workers << Thread.new{ImageWorker.new(@queue).run}
      end

      Archive.where(["status=?",Archive::NEW]).each do |arc|
        arc.adjust_table_width
        @queue<<arc
      end
      @img_workers.size.times {@queue << :END}
      @img_workers.each { |th| th.join }
    end
  end


  class ImageWorker

    def initialize(image_queue)
      @queue=image_queue
      @connections={}
    end    

    def run
      loop do
        archive=@queue.deq
        break if archive==:END
        content_node_set=Nokogiri::HTML(archive.content)
        imgs=content_node_set.xpath('.//img')
        puts "crawl images for #{archive.title} => #{imgs.size} images"
        thumbnail_url=nil
        page_url=URI(archive.url)
        imgs.each do |pi|
          retried_times=0
          # skip noisy images
          #next if html_struct[:noisy_img_patterns].any? {|patt| pi['src']=~ patt}
          begin
            pi['src']=pi['file'] if pi['file']
            url=(page_url.merge(pi['src']))
            next if File.extname(url.path).downcase==".gif"
            flattened_name=url.path.sub(/\//,'').gsub(/\//,'_') 
            save_to=archive.abs_img_path(flattened_name)
            if File.exists? save_to
              puts "Image file already existed."
              next
            end
            http=connection(url)
            # http.read_timeout=10
            # http.open_timeout=10
            req=Net::HTTP::Get.new(url.path)
            req.add_field 'HTTP_REFERER', archive.url
            res=http.request(req)
            next if res.class!=Net::HTTPOK
            puts "DDDDDDDDDDDDDDDDDDDD => #{res.content_type}"
            # add extname if no ext name
            if File.extname(save_to).blank?
              ext=res.content_type.downcase.scan(/image\/(\w+)/)[0][0] rescue nil
              next if ext.nil?
              ext='jpg' if ext=='jpeg'
              save_to+=".#{ext}"
              flattened_name+=".#{ext}"
              puts "NEW SAVE_TO => #{save_to}"
            end
            open(save_to, 'wb' ) { |file| file.write(res.body) }
            img_url_in_archive=File.join(archive.img_url_dir,flattened_name)
            pi['src']=img_url_in_archive
            pi['class']='autosize'
            # remove image hardcode size attribute. 
            %w{width height style onmouseover onclick}.each{|att| pi.remove_attribute att}
            # FIXME Should create small size image as well. 
            ImageScience.with_image(save_to){|thisimg| thumbnail_url=img_url_in_archive if thisimg.width>150} if thumbnail_url.blank?
          rescue Timeout::Error
            retried_times+=1
            puts "Timeout crawl images => #{url.to_s}"
            retry if retried_times<2
            next            
          rescue Exception => e
            puts "Error! #{e.class} => #{e.message}"
            puts e.backtrace
            next
          end
        end
        archive.update_attributes({:content => content_node_set.to_html,:thumbnail => thumbnail_url,:status => Archive::ANALYZED})
      end
    end

    def connection(url)
      @connections[url.host] ||= {}
      if conn = @connections[url.host][url.port]
        return conn
      end
      refresh_connection url
    end
 
    def refresh_connection(url)
      http = Net::HTTP.new(url.host, url.port)
      #http.read_timeout = read_timeout if !!read_timeout
      if url.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      @connections[url.host][url.port] = http.start 
    end   
    
  end
end
