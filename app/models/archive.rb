require 'zip/zipfilesystem'

class Archive < ActiveRecord::Base
  belongs_to :provider

  validates_uniqueness_of :url, :message => "DUPLICATED"

  TINY_THUMB='thumb48'
  SMALL_THUMB='thumb96'
  BIG_THUMB='thumb150'
  # Archive status
  # new => analyzed => synced => locked(verifying by admin) <=> ok(published) => deleted(ignored)
  NEW=0
  ANALYZED=1
  SYNCED=2
  LOCKED=3
  OK=4
  DELETED=5

#  before_create :extract_thumbnail
  before_save :check_pub_date

  def content_dom
    return @dom if not @dom.blank?
    @dom=Nokogiri::HTML(self.content)
  end

  def check_pub_date
    #logger.debug("in Archive check_pub_date method")
    self.pub_date=Time.now.utc if self.pub_date.blank?
    self
  end

  # Remove fixed width of table elements
  def adjust_table_width
    content_dom.xpath('//table').each do |ele|
      ele['width']=''
    end
    self.update_attribute('content',content_dom.to_html)
  end

  def to_zip
    # generate mobile type html file
    File.open(File.join(self.abs_img_dir,"#{self.id}.html"),"w") do |html|
      html.puts('<?xml version="1.0" encoding="UTF-8"?>')
      html.puts('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">')
      html.puts('<html><head>')
      html.puts('<title>Q&A for Mobile</title>')
      html.puts('<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">')
      html.puts('<style type="text/css">.autosize{max-width:100%;}</style>')
      html.puts('</head>')
      html.puts('<body>')
      html.puts('<div>')
      doc=Nokogiri::HTML(self.content)
      doc.xpath("//img[@class='autosize']").each { |img| img["src"]=img["src"].sub(/\/images\/archives\/\d+\//,'') }
      html.puts(doc.to_html)
      html.puts('</div>')
      html.puts('</body></html>')
    end
    # re-generate zip file 
    zip_file=File.join(self.abs_img_dir,"#{self.id}.pkg.zip")
    FileUtils.rm zip_file, :force => true
    Zip::ZipFile.open(zip_file,Zip::ZipFile::CREATE) do |zip|
      zip.dir.mkdir("#{self.id}")
      Dir.foreach(self.abs_img_dir) do |img|
        zip.add("#{self.id}/#{img}","#{self.abs_img_dir}/#{img}") unless img=~/^\./ 
      end
    end
  end

  # deprecate
  def extract_thumbnail
    return self if provider.format!='rss'
    doc=Nokogiri::HTML(self.desc)
    self.content=self.desc if !provider.full_content? && self.content.blank?
    self.desc=doc.content
    if self.thumbnail.blank?
      img=doc.xpath('//img')[0]
      img=Nokogiri::HTML(self.content).xpath('//img')[0] if img.blank?  && provider.full_content
      self.thumbnail=img['src'] unless img.blank?
    end
  end

  def refresh_img_url(old_id)
    return true if self.id==old_id.to_i
    ns=content_dom
    ns.xpath('//img').each do |pi|
      pi['src']=pi['src'].sub(/\/images\/archives\/\d+\//,"/images/archives/#{self.id}/") if pi['class']=='autosize' && pi['src']=~/\/images\/archives\/\d+\//
      logger.debug("AAAA => #{pi['src']}")
    end
    self.thumbnail=self.thumbnail.sub(/\/images\/archives\/\d+\//,"/images/archives/#{self.id}/")
    self.content=ns.to_html 
    self.save
  end

  def crawl_imgs()
    puts "crawl images of #{self.title}"
    thumbnail_url=nil
    content_node_set=Nokogiri::HTML(self.content)
    page_url=URI(self.url)
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
          flattened_name=url.path.sub(/\//,'').gsub(/\//,'_')   
          iwp=File.join(img_warehouse_dir,flattened_name)
          unless File.exists? iwp 
            puts "Image file does not exist, crawl it."
            http=Net::HTTP.new(url.host,url.port)
            http.read_timeout=10
            http.open_timeout=10
            req=Net::HTTP::Get.new(url.path)
            req.add_field 'HTTP_REFERER', self.url
            res=http.request(req)
            Thread.exit if res.class!=Net::HTTPOK
            open(iwp, 'wb' ) { |file|
              file.write(res.body)
            }
          end
          FileUtils.cp(iwp,abs_img_path(flattened_name))
          img_url_in_archive=File.join(img_url_dir,flattened_name)
          pi['src']=img_url_in_archive
          pi['class']='autosize'
          # remove image hardcode size attribute. 
          %w{width height style onmouseover onclick}.each{|att| pi.remove_attribute att}
          # FIXME Should create small size image as well. 
          ImageScience.with_image(iwp){|thisimg| thumbnail_url=img_url_in_archive if thisimg.width>150} if thumbnail_url.blank?
        rescue Exception => e
          puts "Error occurred when crawl images => #{e}"
          puts "Image url => #{url.to_s}"
          puts e.backtrace
          Thread.exit
        end
      end
    end
    threads.each {|thr| thr.value}
    self.update_attributes({:content => content_node_set.to_html,:thumbnail => thumbnail_url,:status => ANALYZED})
  end

  def all_image_filenames
    return @images unless @images.blank?
    @images=[]
    Dir.foreach(self.abs_img_dir) do |file|
      @images<<file unless file=~/^\./
    end
    @images
  end

  def img_warehouse_dir
    return @iwd unless @iwd.blank?
    @iwd=File.join(Rails.root,"/public/images/crawl")
    FileUtils.mkdir_p(@iwd) unless File.exists? @iwd
    @iwd
  end

  def abs_img_path(img_name)
    File.join(abs_img_dir,img_name)
  end

  def img_url_path(img_name)
    File.join(img_url_dir,img_name)
  end

  # dir part of the image url
  def img_url_dir
    return @ird unless @ird.blank?
    @ird=File.join("/images/archives",self.id.to_s)
  end

  # absolute path of the dir to save images of an archive
  def abs_img_dir
    return @aid unless @aid.blank?
    @aid=File.join(Rails.root,"public",img_url_dir)
    FileUtils.mkdir_p(@aid) unless File.exists? @aid
    @aid
  end

  def zip_url_path()
    File.join(img_url_dir,"#{self.id}.pkg.zip")
  end

  def thumb_filenames()
    return BIG_THUMB,SMALL_THUMB,TINY_THUMB #"thumb150","thumb96","thumb48"
  end

  def small_thumb_url_path
    img_url_path(SMALL_THUMB)
  end
  def tiny_thumb_url_path
    img_url_path(TINY_THUMB)
  end
  def big_thumb_url_path
    img_url_path(BIG_THUMB)
  end

  def locked?
    self.status==LOCKED
  end

  def ok?
    self.status==OK
  end

  def analyzed?
    self.status==ANALYZED    
  end

  def synced?
    self.status==SYNCED
  end

end
