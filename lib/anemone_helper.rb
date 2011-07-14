# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'fileutils'
class AnemoneHelper

  # add other site structs if added new forum into Provider.
  @@forum_html_structs = {
      'default' => {
        :thread_list_xpath => "//div[@id='threadlist']/form/table/tbody/tr",
        :wrote_dat_in_thread_list_xpath => "td[@class='author']/em",
        :hit_count_in_thread_list_xpath => "td[@class='nums']/em",
        :author_id_url_in_thread_list_xpath => "td[@class='author']/cite/a",
        :author_id_in_thread_list_scan_regexp => '\d+',
        :view_author_only_url_xpath => "//div[@class='authorinfo']/a",
        :noisy_img_patterns => []
      },
      'bbs.rayli.com.cn' => {
        :thread_list_xpath => "//div[@id='threadlist']/form/table/tbody/tr",
        :wrote_dat_in_thread_list_xpath => "td[@class='author']/em",
        :hit_count_in_thread_list_xpath => "td[@class='nums']/em",
        :author_id_url_in_thread_list_xpath => "td[@class='author']/cite/a",
        :author_id_in_thread_list_scan_regexp => '\d+',
        :view_author_only_url_xpath => "//div[@class='authorinfo']/a",
        :noisy_img_patterns => [/rl01\/images\/attachimg.gif/]
      },
      'club.eladies.sina.com.cn' => {
        :thread_list_xpath => "//div[@id='data_list']/form/table/tbody/tr",
        :wrote_dat_in_thread_list_xpath => "td[@class='author']/em",
        :hit_count_in_thread_list_xpath => "td[@class='nums']/em",
        :author_id_url_in_thread_list_xpath => "td[@class='author']/cite/a",
        :author_id_in_thread_list_scan_regexp => '\d+',
        :view_author_only_url_xpath => "//div[@class='myInfo_up']/a[2]",
        :noisy_img_patterns => [/rl01\/images\/attachimg.gif/]
      },
    }

  def initialize(provider)
    @provider=provider
    @ane_opts={
      :charset => @provider.encoding,
      :depth_limit => @provider.max_crawl_depth,
      :threads => 8,
      :verbose => false,
      }
    @patterns=prepare_url_patterns
    @site=@provider.url
  end
  
  def start_crawl()
    Anemone.crawl(@site,@ane_opts) do |ane|
      ane.skip_links_like *@patterns[:skip_patterns] if @patterns[:skip_patterns].size > 0
      ane.focus_crawl do |page|
        self.send("#{@provider.struct}_filter_links",page)
      end
      ane.on_pages_like(*@patterns[:archive_patterns]) do |page|
        fetch_content(page)
        page.discard_doc!
      end
    end
  end

  # For forums we only focus on three kinds of page.
  # 1) Thread list page. In thread list page delete all links except:
  #   a) links that point to a post and the post is a new one and looks like a good post.
  #   b) links that point to next page of thread list.
  #
  # 2) The page shows content contributed by author and comments from others. Delete
  #    all links in post page except the link point to the url of "show author only"
  # 3) The page that only contains content which was wrote by author. This this the
  #    termination of crawl action.
  def bbs_filter_links(page)
    html_struct=@@forum_html_structs[page.url.host]
    arr=page.links
    i=arr.size
    # delete all link that should not be crawl.
    arr=arr.delete_if {|l|@patterns[:follow_patterns].all? {|patt| (l.to_s=~patt)==nil}}
    if page.url.to_s=~@patterns[:follow_patterns].first
      threadlist=page.doc.xpath(html_struct[:thread_list_xpath])
      threadlist.each do |tr|
        #FIXME keep consistent time-zone in background.
        wrote_date=DateTime.parse(tr.xpath(html_struct[:wrote_dat_in_thread_list_xpath])[0].content) rescue Time.now-100.day
        hit_count=tr.xpath(html_struct[:hit_count_in_thread_list_xpath])[0].content.to_i rescue 0
        #author_id=tr.xpath(html_struct[:author_id_url_in_thread_list_xpath])[0]['href'].scan(Regexp.new(html_struct[:author_id_in_thread_list_scan_regexp]))[0] rescue '0'
        # delete links that was not new post or the post is not hot
        if (wrote_date+@provider.max_age.day<Time.now) || hit_count<@provider.min_hit #|| author_id=='0'
          tr.xpath(".//a").each { |a|arr.delete(page.to_absolute(URI(a['href'])))}
        else
          #page.to_absolute(URI(a['href']))
        end
      end
      page.discard_doc!
      arr
    elsif page.url.to_s=~@patterns[:follow_patterns][1]
      # This is a post url and extract the only url of '只看该作者' in this page
      author_url=page.to_absolute(URI(page.doc.xpath(html_struct[:view_author_only_url_xpath])[0]['href'])) rescue ''
      page.discard_doc!
      arr=(author_url.blank? || Archive.exists?(:url =>  author_url.to_s)) ? arr.clear : [author_url]
    elsif page.url.to_s=~@patterns[:follow_patterns].last
      # cleare all url of this page
      arr.clear
    else
      page.discard_doc!
      arr.clear
    end
    puts "Links filter result #{i} => #{arr.size}"
    arr
  end

  def portal_filter_links(page)
    arr=page.links
    if @patterns[:archive_patterns].any? {|p|page.url.to_s=~p}
      return arr.clear 
    elsif @patterns[:follow_patterns].any? {|p|page.url.to_s=~p}
      page.discard_doc!
      arr=page.links.inject([]) do |array,link|
        array<<link if @patterns[:follow_patterns].any? {|p|link.to_s=~p}
        array<<link if @patterns[:archive_patterns].any? {|p|link.to_s=~p}
        array
      end
      return arr
    else
      page.discard_doc!
      return arr.clear
    end
  end

  # The fetch_content method are general for all final archive html document.
  # The process is:
  # 1) Ignore that was already saved.
  # 2) Extract nodes for title, content and publish date. Ignore this if either one of them are missing.
  # 3) Convert publish time string to DateTime and ignore if this archive is published 3 days ago.
  #    FIXME: the publish date should be converted to correct time-zone before using.
  #    FIXME: the published condition shoudl be configurable to a provider.
  # 4) Convert all images in the archive if provider has fake the image src attribute
  #    FIXME: the un-fake action should be configurable to a provider.
  # 5) Save this archive to DB.
  def fetch_content(page)
    if @provider.uid_pattern.blank?
      return if Archive.exists?(:url => page.url.to_s)
    else
      uid=page.url.to_s.scan(Regexp.new(@provider.uid_pattern))[0] rescue page.url.to_s
      return if Archive.exists?(:uid => uid)
    end
    puts "Find a new archive that was not in DB #{page.url}"
    # Get title of the html
    if page.doc.blank?
      puts "!!! page#doc method is nil!!!!!  => #{page.url.to_s}"
      return
    end
    title_node=page.doc.at_css('title','TITLE')
    # Get Content
    content_node_set=page.doc.send(@provider.search_node_method,@provider.content_xpath)
    pub_date_node=page.doc.xpath(@provider.pub_date_xpath)[0]
    # Next if can't get title, content and publish date
    return if title_node.blank? || content_node_set.size<1 || pub_date_node.blank?
    pub_time=DateTime.parse(pub_date_node.content.scan(Regexp.new(@provider.regex_for_scan_pub_date))[0]) rescue return
    # Ignore that was published 3 days ago.
    # FIXME keep time zone consistent with DB.
    return if pub_time+@provider.max_age.day<Time.now
    # fuck correct imgs that was hidden by forum
    content_node_set.xpath('.//img').each { |pic| pic['src']=pic['file'] unless pic['file'].blank?}
    save_fetched_content_to_achive(page,title_node,pub_time,content_node_set,nil)
  end

  def save_fetched_content_to_achive(page,title_node,pub_time,content_node_set,thumbnail)
    title=title_node.content
    desc_meta=page.doc.xpath("//meta[@name='description']")[0]
    keywords_meta=page.doc.xpath("//meta[@name='keywords']")[0]
    url=page.url.to_s
    uid=@provider.uid_pattern.blank? ? url : url.scan(Regexp.new(@provider.uid_pattern))[0] rescue url
    Archive.create({
        :title => title,:url => url, :uid => uid,
        :pub_date => pub_time,
        :desc => desc_meta.blank? ? '' : desc_meta['content'],
        :keywords => keywords_meta.blank? ? '' : keywords_meta['content'],
        :content => content_node_set.inject(''){|c,i|c+=i.to_html(:encoding => 'utf-8')} ,
        :thumbnail => thumbnail,
        :provider_id => @provider.id,
        :cat => @provider.category.alias,
    })
    puts "Saved archive #{title.truncate(20)} to DB"
  end

  # Fetch all images save into local and then select one image as thumbnail
  def self.extract_thumbnail(archive)
    thumbnail_url=nil
    content_node_set=Nokogiri::HTML(archive.content)
    page_url=URI(archive.url)
    thumbnail_url=nil
    imgs=content_node_set.xpath('.//img')
    threads=[]
    imgs.each do |pi|
      # skip noisy images
      #next if html_struct[:noisy_img_patterns].any? {|patt| pi['src']=~ patt}
      threads<<Thread.new do
        begin        
          #puts pi['src']
          url=(page_url.merge(pi['src']))
          Thread.exit if File.extname(url.path).downcase==".gif"
          save_img_relative_path=File.join("/images/crawl",url.path)
          save_img_absolute_path=File.join(Rails.root,"/public",save_img_relative_path)
          unless File.exists? save_img_absolute_path
            http=Net::HTTP.new(url.host,url.port)
            http.read_timeout=10
            http.open_timeout=10
            req=Net::HTTP::Get.new(url.path)
            req.add_field 'HTTP_REFERER', archive.url
            res=http.request(req)
            Thread.exit if res.class!=Net::HTTPOK
            save_to_dir=File.dirname(save_img_absolute_path)
            FileUtils.mkdir_p(save_to_dir) unless File.exists? save_to_dir
            open(save_img_absolute_path, 'wb' ) { |file|
              file.write(res.body)
            }
          end
          pi['src']=save_img_relative_path
          ImageScience.with_image(save_img_absolute_path){|thisimg| thumbnail_url=save_img_relative_path if thisimg.width>150} if thumbnail_url.blank?
        rescue Exception => e
          puts "Error occurred when crawl images => #{e}"
          Thread.exit
        end
      end
    end
    threads.each {|thr|puts thr.value}
    archive.update_attributes({:content => content_node_set.to_html,:thumbnail => thumbnail_url})
  end

  def prepare_url_patterns()
    follow_patterns=@provider.url_patterns_to_follow.split(/\s/).inject(Array.new){|arr,i| i.blank? ? arr : arr<<Regexp.new(i) }
    #puts @provider.url_patterns_to_follow
    skip_patterns=@provider.url_patterns_to_skip.split(/\s/).inject([]){|arr,i| i.blank? ? arr : arr<<Regexp.new(i) } rescue []
    archive_patterns=@provider.archive_url_patterns.split(/\s/).inject([]){|arr,i| i.blank? ? arr : arr<<Regexp.new(i) }
    archive_patterns<<follow_patterns.last if archive_patterns.size==0
    {
      :follow_patterns => follow_patterns,
      :skip_patterns => skip_patterns,
      :archive_patterns => archive_patterns
    }
  end


  def portal_fetch_content(page)
    return if Archive.exists?(:url => page.url.to_s)
    puts "Find a new archive that was not in DB #{page.url}"
    # Get title of the html
    if page.doc.blank?
      puts "!!! page#doc method is nil!!!!!  => #{page.url.to_s}"
      return
    end
    title_node=page.doc.at_css('title','TITLE')
    # Get Content
    content_node_set=page.doc.send(@provider.search_node_method,@provider.content_xpath)
    # fuck correct imgs that was hidden by forum
    content_node_set.xpath('.//img').each { |pic| pic['src']=pic['file'] unless pic['file'].blank?}
    pub_date_node=page.doc.xpath(@provider.pub_date_xpath)[0]
    # Next if can't get title, content and publish date
    return if title_node.blank? || content_node_set.size<1 || pub_date_node.blank?
    pub_time=DateTime.parse(pub_date_node.content.scan(Regexp.new(@provider.regex_for_scan_pub_date))[0]) rescue return
    # Ignore that was published 3 days ago.
    # FIXME keep time zone consistent with DB.
    return if pub_time+2.day<Time.now
    #puts "Publish date of this archive is ok!"
    save_fetched_content_to_achive(page,title_node,pub_time,content_node_set,nil)
    puts "Saved archive #{title_node.content.truncate(20)} to DB"
  end

  def bbs_fetch_content(page)
    #html_struct=@@forum_html_structs[page.url.host]
    return if Archive.exists?(:url => page.url.to_s)
    puts "Find a new archive that was not in DB #{page.url}"
    # Get title of the html
    if page.doc.blank?
      puts "!!! page#doc method is nil!!!!!  => #{page.url.to_s}"
      return
    end
    title_node=page.doc.at_css('title','TITLE')
    # Get Content
    content_node_set=page.doc.send(@provider.search_node_method,@provider.content_xpath)
    # fuck correct imgs that was hidden by forum. Currently only find rayli.com need to be fuck
    content_node_set.xpath('.//img').each { |pic| pic['src']=pic['file'] unless pic['file'].blank?}
    pub_date_node=page.doc.xpath(@provider.pub_date_xpath)[0]
    # Next if can't get title, content and publish date
    return if title_node.blank? || content_node_set.size<1 || pub_date_node.blank?
    pub_time=DateTime.parse(pub_date_node.content.scan(Regexp.new(@provider.regex_for_scan_pub_date))[0]) rescue return
    # Ignore that was published 3 days ago.
    # FIXME keep time zone consistent with DB.
    return if pub_time+2.day<Time.now
    puts "Publish date of this archive is ok!"
    save_fetched_content_to_achive(page,title_node,pub_time,content_node_set,nil)
  end

end
