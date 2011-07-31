require 'nokogiri'
require 'time'

#module Crawl
  
  # This class is used to help parse a html page and extract
  # useful content according the given source configuration.
  class GeneralAnalyser
    
    attr_accessor :source
    
    def initialize(source)
      @source=source
    end

    # extract all links that is point to an archive need to crawl.
    def extract_links(page)
      page.links(@source[:archive_patterns])
    end
    
    # Extract content from html, and save the content to db.
    def extract_content(page)
      # calculate archive unique id
      uid=page.url.to_s.scan(@source[:unique_id_pattern])[0][0] rescue page.url.to_s
      uid=@source[:name]+"-"+uid
      #puts "UID is =>#{uid}"
      # FIXME Check whether this archive is already existed in db.
      
      # Check title and Content. If title or content was nil then return
      title=page.doc.at_css('title','TITLE').content
      content_node_set=fetch_content_nodes(page)
      return false,"title blank" if title.blank? || content_node_set.size<1
      # FIXME Check picture counts, ignore archives which has less than 5 pictures
      img_nodes=content_node_set.css('img')
      return false,"No enough images#{img_nodes.size}" if img_nodes.size<3
      
      # Check archive publish time filter old archives
      pub_time=fetch_pub_time(page) 
      #puts "Pub time is=> #{pub_time}"
      return false,"pub time nil" if pub_time.nil?
      return false,"Archive too old #{pub_time}" if (pub_time+(@source[:max_age].days))<Time.now
      # Do some extra work if needed
      extra_work(content_node_set) if self.respond_to?(:extra_work)
      # Get document META info
      desc_meta=page.doc.xpath("//meta[@name='description']")[0]
      keywords_meta=page.doc.xpath("//meta[@name='keywords']")[0]
      analyzed_page={
        :title => title, :url => page.url.to_s, :uid => uid, 
        :pub_date => pub_time, 
        :desc => desc_meta.blank? ? '' : desc_meta['content'],
        :keywords => keywords_meta.blank? ? '' : keywords_meta['content'],
        :content => content_node_set.inject(''){|c,i|c+=i.to_html(:encoding => 'utf-8')} ,
      }  
      return true,analyzed_page
      #yield analyzed_page if block_given?
      #return analyzed_page
    end
    
    
    def fetch_content_nodes(page)
      content_node_set=page.doc.send(@source[:search_content_node_method]||'xpath',@source[:content_path_expression])
    end
    
    def fetch_pub_time(page)
      #puts "pub date css => #{@source[:pub_date_css]}"
      pub_date_node=page.doc.at_css(@source[:pub_date_css])
      #puts "pub date note text =>#{pub_date_node.text}"
      #puts "pub date string is => #{pub_date_node.content.scan(@source[:pub_date_pattern])[0][0]}"
      Time.parse(pub_date_node.content.scan(@source[:pub_date_pattern])[0][0]) rescue nil
    end

    #
    # Converts relative URL *link* into an absolute URL based on the
    # location of the page
    #
    def to_absolute(link)
      return nil if link.nil?

      # remove anchor
      link = URI.encode(URI.decode(link.to_s.gsub(/#[a-zA-Z0-9_-]*$/,'')))

      relative = URI(link)
      absolute = @url.merge(relative)

      absolute.path = '/' if absolute.path.empty?

      return absolute
    end

  end
  
  
  
  class ForumAnalyser < GeneralAnalyser
    # extract all links that is point to an archive need to crawl.
    # For bbs go through all the thread and get thread id, author id etc. 
    # Then generate a link to a Post.
    def extract_links(page)
      links=[]
      threadlist=page.doc.xpath(@source[:thread_list_xpath])
      threadlist.each do |thr|
        next if top?(thr)
        next if split?(thr)
        next if old?(thr)
        next if !hot?(thr)
        link=@source[:link_template].sub(/#THRID#/,thread_id(thr)).sub(/#AUTHID#/,author_id(thr)) rescue nil
        links << link if not link.nil?
      end
      links
    end
    
    def author_id(node)
      author_url=node.xpath(@source[:author_id_url_in_thread_list_xpath])[0]['href'] rescue nil
      auth_id=author_url.scan(@source[:author_id_scan_pattern])[0][0] rescue nil
    end
    
    
    def top?(node)
      node["id"]=~/^stickthread/
    end
    
    def split?(node)
      node["id"].nil?
    end
    
    def old?(node)
      wrote_date=Time.parse(node.xpath(@source[:wrote_date_in_thread_list_xpath])[0].content) rescue nil
      res=(wrote_date + @source[:max_age].day < Time.now) rescue false
    end
    
    def hot?(node)
      hit_count=node.xpath(@source[:hit_count_in_thread_list_xpath])[0].content.to_i rescue 0
      #puts "hit count => #{hit_count}"
      hit_count > @source[:min_hit]
    end
    
    def thread_id(node)
      node["id"].scan(@source[:thread_id_pattern])[0][0] rescue nil
    end

  end

#end
